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
    return unless context.present?

    send(context, txt)
  end

  def handle_callback(data)
    callback_type, command = data.split(':')
    case callback_type
    when 'groups', 'group', 'choose_group'
      ::Bots::GroupCallback.new(self).handle(callback_type, command)
    end
  end

  def add_group(group_name)
    group = ::Group.create!(name: group_name, chat_id: chat.id)
    send_message(msg: "Создана группа `#{group.name}`")
    delete_context
  rescue ActiveRecord::RecordInvalid => e
    send_message(msg: e.record.errors.full_messages.join("\n"))
  end

  def edit_group(txt)
    callback_handler = ::Bots::GroupCallback.new(self)
    group = ::Group.where(chat: chat).find_by!(name: callback_handler.target)
    group.name = txt
    group.save!

    send_message(msg: 'Группа успешно изменена')
    delete_context
  rescue ActiveRecord::RecordNotFound => e
    send_message(msg: 'Группа не найдена')
  rescue ActiveRecord::RecordInvalid => e
    send_message(msg: e.record.errors.full_messages.join("\n"))
  end

  def add_clients(txt)
    return send_message(msg: 'Неверный формат') unless /\A((@[a-zA-Z0-9_-]+) ?)+\z/.match(txt)

    callback_handler = ::Bots::GroupCallback.new(self)
    clients = txt.gsub('@', '').split
    group = ::Group.where(chat: chat).find_by!(name: callback_handler.target)
    users = ::User.where(telegram_username: clients, chat: chat)

    users.each do |user|
      group.users << user
      send_message(msg: "Пользователь @#{user.telegram_username} добавлен в группу `#{group.name}`")
    rescue ActiveRecord::RecordInvalid => e
      send_message(msg: e.record.errors.full_messages.join("\n"))
    end
    delete_context
  rescue ActiveRecord::RecordNotFound => e
    send_message(msg: 'Группа не найдена')
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
