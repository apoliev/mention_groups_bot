class Bot
  CONTEXTS = %i[
    add_group
    edit_group
    add_clients
  ].freeze

  attr_reader :bot, :chat, :user

  def initialize(chat, user)
    @bot = Telegram.bot
    @chat = chat
    @user = user
    @context_handler = ::ContextHandler.new(self)
    @callback_handler = ::CallbackHandler.new(self)
  end

  def user_admin?
    data = bot.get_chat_member(chat_id: chat.telegram_chat_id, user_id: user.telegram_user_id)
    status = data.dig('result', 'status')

    %w[creator administrator].include?(status)
  end

  def send_message(text:, **opts)
    options = {
      chat_id: chat.telegram_chat_id,
      text:,
      parse_mode: 'Markdown'
    }.merge(opts)

    bot.send_message(**options)
  end

  def add_context(context)
    @context_handler.add_context(context)
  end

  def delete_context
    @context_handler.delete_context
  end

  def context
    @context_handler.context
  end

  def handle_context(txt)
    @context_handler.handle(txt)
  end

  def add_target(target)
    @callback_handler.add_target(target)
  end

  def delete_target
    @callback_handler.delete_target
  end

  def target
    @callback_handler.target
  end

  def handle_callback(data)
    @callback_handler.handle(data)
  end
end
