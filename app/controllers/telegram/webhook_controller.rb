class Telegram::WebhookController < Telegram::Bot::UpdatesController
  before_action :check_left
  before_action :set_chat
  before_action :set_user
  before_action :set_mention_bot
  before_action :check_admin, except: %i[help! groups! all! action_missing message]

  class LeftChat < ::StandardError; end
  class NotGroupChat < ::StandardError; end
  class NotAdmin < ::StandardError; end
  class UserError < ::StandardError; end

  rescue_from LeftChat do |e|
  end

  rescue_from NotGroupChat do |e|
  end

  rescue_from NotAdmin do |e|
  end

  rescue_from UserError do |e|
  end

  def callback_query(data)
    edit_message :text, **@mention_bot.handle_callback(data)
  end

  def edited_message(*args)
    message(*args)
  end

  def message(data, *_args)
    return @mention_bot.handle_event(data) if data['text'].blank?

    bot_action = %r{/(?<action>[a-z_]+)(@.+)?}.match(data['text'])
    if bot_action && bot_action[:action].present?
      method = "#{bot_action[:action]}!"

      respond_to?(method) ? send(method) : action_missing("#{bot_action[:action]}!")
    else
      @mention_bot.handle_context(data['text'])
    end
  end

  def help!
    respond_with :message, text: t('telegram.help')
  end

  def all!(*_args)
    msg = @chat.users.where.not(telegram_user_id: @user.telegram_user_id).map do |u|
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
      msg = @chat.groups.map { |g| "- #{g.name}" }.join("\n")
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

  def action_missing(action, *args)
    if action == 'my_chat_member'
      chat_member_status = args[0].dig('new_chat_member', 'status')

      if %w[kicked left].include?(chat_member_status)
        @chat.destroy
        return
      end
    end

    group = @chat.groups.find_by(name: action.gsub('!', ''))

    return if group.blank?

    msg = group.users.where.not(id: @user.id).map { |u| "@#{u.telegram_username}" }.join(' ')
    respond_with :message, text: msg if msg.present?
  end

  private

  def check_left
    left_bot_id = update.dig('message', 'left_chat_member', 'id')
    raise LeftChat if left_bot_id.present? && (left_bot_id == bot.get_me.dig('result', 'id'))
  end

  def migrate_chat(chat, new_chat_id)
    new_chat = Chat.includes(:users, :groups).find_by(telegram_chat_id: new_chat_id)
    return if new_chat.nil?

    Chat.transaction do
      new_chat.users = (new_chat.users + chat.users).uniq
      new_chat.groups += chat.groups

      chat.reload.destroy
    end
  end

  def set_chat
    raise NotGroupChat unless %w[group supergroup].include?(chat.fetch('type'))

    @chat = Chat.includes(:users, :groups).find_or_create_by(telegram_chat_id: chat.fetch('id'))
    migrate_chat_id = update.dig('message', 'migrate_to_chat_id')
    return unless migrate_chat_id

    migrate_chat(@chat, migrate_chat_id)
    raise LeftChat
  end

  def set_user
    if from['username'].blank?
      respond_with(
        :message,
        text:         I18n.t('telegram.user_without_username'),
        parse_mode:   'MarkdownV2',
        reply_markup: {
          inline_keyboard: [
            [
              {
                text: I18n.t('telegram.add_username_help'),
                url:  'https://telegram.org/faq#q-what-are-usernames-how-do-i-get-one'
              }
            ]
          ]
        }
      )

      raise UserError
    end

    raise UserError if from['is_bot']

    @user = User.where(telegram_user_id: from.fetch('id')).first_or_initialize(
      telegram_user_id:  from.fetch('id'),
      telegram_username: from['username']
    )

    @user.save! if @user.new_record?
    @user.chats << @chat unless @chat.users.include?(@user)
  rescue ActiveRecord::RecordInvalid => e
    respond_with(:message, text: e.record.errors.full_messages.join("\n"))
    raise UserError
  end

  def set_mention_bot
    @mention_bot = ::Bot.new(@chat, @user)
  end

  def check_admin
    return unless action_methods.include?(action_name)

    raise NotAdmin unless @mention_bot.user_admin?
  end
end
