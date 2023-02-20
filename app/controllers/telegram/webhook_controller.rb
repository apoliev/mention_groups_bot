class Telegram::WebhookController < Telegram::Bot::UpdatesController
  before_action :set_user
  before_action :set_chat
  before_action :set_mention_bot
  before_action :check_admin, except: %i[groups! all!]

  class NotGroupChat < ::StandardError; end
  class NotAdmin < ::StandardError; end

  rescue_from NotGroupChat do |e|
  end

  rescue_from NotAdmin do |e|
  end

  def message(data)
    @mention_bot.handle_context(data.fetch('text'))
  end

  def all!
    msg = User.where.not(telegram_user_id: @user.telegram_user_id).map { |u| "@#{u.telegram_username}" }.join(' ')
    respond_with :message, text: msg
  end

  def add_group!
    @mention_bot.add_context(:add_group)
    respond_with :message, text: 'Напишите название группы'
  end

  def groups!
    msg = Group.all.map { |g| "- #{g.name}" }.join("\n")
    respond_with :message, text: msg
  end

  def cancel!
    context = @mention_bot.context
    return if context.blank?

    @mention_bot.delete_context
    respond_with :message, text: "Команда `#{context}` отменена", parse_mode: 'Markdown'
  end

  private

  def set_user
    @user = User.find_or_create_by(telegram_user_id: from.fetch('id'))

    return unless !@user.telegram_username? || (@user.updated_at + 1.month) <= Time.zone.now

    @user.telegram_username = from['username']
    @user.name = "#{from['last_name']} #{from['first_name']}".strip
    @user.save
  end

  def set_chat
    raise NotGroupChat unless chat.fetch('type') == 'group'

    @chat = Chat.find_or_create_by(telegram_chat_id: chat.fetch('id'))
  end

  def set_mention_bot
    @mention_bot = ::Bot.new(@chat, @user)
  end

  def check_admin
    raise NotAdmin unless @mention_bot.user_admin?
  end
end
