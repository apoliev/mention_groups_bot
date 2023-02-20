class Bot
  CONTEXTS = %i[
    add_group
  ].freeze

  attr_reader :bot, :chat, :user

  def initialize(chat, user)
    @bot = Telegram.bot
    @chat = chat
    @user = user
  end

  def user_admin?
    data = bot.get_chat_member(chat_id: chat.telegram_chat_id, user_id: user.telegram_user_id)
    status = data.dig('result', 'status')

    %w[creator administrator].include?(status)
  end

  def add_context(context)
    return unless CONTEXTS.include?(context)

    Rails.cache.write(context_key, context, expires_in: 1.hour)
  end

  def delete_context
    Rails.cache.delete(context_key)
  end

  def context
    Rails.cache.read(context_key)
  end

  def handle_context(txt)
    case context
    when :add_group
      add_group(txt)
    end
  end

  def add_group(group_name)
    group = ::Group.create!(name: group_name, chat_id: chat.id)
    send_message(msg: "Создана группа `#{group.name}`")
    delete_context
  rescue ActiveRecord::RecordInvalid => e
    send_message(msg: e.record.errors.full_messages.join("\n"))
  end

  private

  def context_key
    { chat_id: chat.telegram_chat_id, user_id: user.telegram_user_id, type: :context }
  end

  def send_message(msg:, link: nil)
    options = {
      chat_id: chat.telegram_chat_id,
      text: msg,
      parse_mode: 'Markdown'
    }

    if link.present?
      options.merge!(
        {
          reply_markup: {
            inline_keyboard: [
              [{ text: 'Перейти', url: link }]
            ]
          }
        }
      )
    end

    bot.send_message(**options)
  end
end
