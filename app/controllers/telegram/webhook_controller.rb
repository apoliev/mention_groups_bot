class Telegram::WebhookController < Telegram::Bot::UpdatesController
  before_action :set_chat
  before_action :set_user
  before_action :set_mention_bot
  before_action :check_admin, except: %i[help! groups! all! action_missing]

  class NotGroupChat < ::StandardError; end
  class NotAdmin < ::StandardError; end
  class UserWithoutUsername < ::StandardError; end

  rescue_from NotGroupChat do |e|
  end

  rescue_from NotAdmin do |e|
  end

  rescue_from UserWithoutUsername do |e|
  end

  def callback_query(data)
    edit_message :text, **@mention_bot.handle_callback(data)
  end

  def message(data, *_args)
    return if data['text'].blank?

    bot_action = %r{\A/(?<action>.+)@.+\z}.match(data['text'])
    if bot_action && bot_action[:action].present?
      send("#{bot_action[:action]}!")
    else
      @mention_bot.handle_context(data['text'])
    end
  end

  def help!
    respond_with :message, text: t('telegram.help')
  end

  def all!(*_args)
    msg = User.with_username.where(chat: @chat).where.not(telegram_user_id: @user.telegram_user_id).map do |u|
      "@#{u.telegram_username}"
    end.join(' ')
    respond_with :message, text: msg unless msg.empty?
  end

  def add_group!(*_args)
    @mention_bot.add_context(:add_group)
    respond_with :message, text: t('telegram.add_group')
  end

  def groups!(*_args)
    if @mention_bot.user_admin?
      ::CallbackHandler.new(@mention_bot).groups
    else
      msg = ::Group.where(chat: @chat).map { |g| "- #{g.name}" }.join("\n")
      if msg.empty?
        respond_with :message, text: t('telegram.group_not_exist')
      else
        respond_with :message, text: msg
      end
    end
  end

  def add!(*_args)
    ::CallbackHandler.new(@mention_bot).groups_for_choose
  end

  def cancel!(*_args)
    context = @mention_bot.context
    return if context.blank?

    @mention_bot.delete_context
    respond_with :message, text: t('telegram.command_canceled', command: context), parse_mode: 'Markdown'
  end

  def action_missing(action, *_args)
    group = ::Group.where(chat: @chat).find_by(name: action.gsub('!', ''))

    return if group.blank?

    msg = group.users.with_username.where.not(id: @user.id).map { |u| "@#{u.telegram_username}" }.join(' ')
    respond_with :message, text: msg if msg.present?
  end

  private

  def set_chat
    raise NotGroupChat unless chat.fetch('type') == 'group'

    @chat = Chat.find_or_create_by(telegram_chat_id: chat.fetch('id'))
  end

  def set_user
    if from['username'].blank?
      respond_with(
        :message,
        text: I18n.t('telegram.user_without_username'),
        parse_mode: 'Markdown',
        reply_markup: {
          inline_keyboard: [
            [
              {
                text: I18n.t('telegram.add_username_help'),
                url: 'https://telegram.org/faq#q-what-are-usernames-how-do-i-get-one'
              }
            ]
          ]
        }
      )

      raise UserWithoutUsername
    end

    @user = User.where(telegram_user_id: from.fetch('id'), chat_id: @chat.id).first_or_initialize(
      telegram_user_id: from.fetch('id'),
      chat_id: @chat.id,
      telegram_username: from.fetch('username')
    )

    @user.save if @user.new_record?
  end

  def set_mention_bot
    @mention_bot = ::Bot.new(@chat, @user)
  end

  def check_admin
    return unless action_methods.include?(action_name)

    raise NotAdmin unless @mention_bot.user_admin?
  end
end
