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

  def sanitize(msg)
    msg.gsub(/[_*\[\]()~`>#+-=|{}.!\\]/, '\\\\\0')
  end

  def send_message(text:, **opts)
    with_sanitize = opts.delete(:sanitize) { true }

    options = {
      chat_id:    chat.telegram_chat_id,
      text:       with_sanitize ? sanitize(text) : text,
      parse_mode: 'MarkdownV2'
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

  def handle_event(data)
    if data['new_chat_members']
      add_new_members(data['new_chat_members'])
    elsif data.dig('left_chat_member', 'is_bot')
      chat.destroy if bot.get_me.dig('result', 'id') == data.dig('left_chat_member', 'id')
    elsif data['left_chat_member']
      delete_chat_member(data['left_chat_member'])
    end
  end

  private

  def add_new_members(members)
    members.each do |data|
      next if data['is_bot']

      new_member = User.where(telegram_user_id: data.fetch('id')).first_or_initialize(
        telegram_user_id:  data.fetch('id'),
        telegram_username: data['username']
      )

      new_member.save! if new_member.new_record?
      new_member.chats << chat unless chat.reload.users.include?(new_member)
    end
  rescue ActiveRecord::RecordInvalid => e
    send_message(text: e.record.errors.full_messages.join("\n"))
  end

  def delete_chat_member(member)
    user = User.find_by(telegram_user_id: member.fetch('id'))
    user.user_groups.joins(:group).where(group: { chat_id: chat.id }).destroy_all
    user.user_chats.where(chat_id: chat.id).destroy_all
  end
end
