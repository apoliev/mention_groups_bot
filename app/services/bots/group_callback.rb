module Bots
  class GroupCallback < Callback
    attr_reader :mention_bot

    def initialize(mention_bot)
      @mention_bot = mention_bot
    end

    def groups
      mention_bot.bot.send_message(chat_id: mention_bot.chat.telegram_chat_id, **all_groups)
    end

    def groups_for_choose
      groups = ::Group.where(chat: mention_bot.chat).order(:id)

      if groups.present?
        mention_bot.bot.send_message(
          chat_id: mention_bot.chat.telegram_chat_id,
          text: 'В какую группу хотите добавить?',
          reply_markup: {
            inline_keyboard: groups.each_slice(2).map do |batch|
              batch.map do |group|
                { text: group.name, callback_data: "choose_group:#{group.name}" }
              end
            end
          }
        )
      else
        mention_bot.bot.send_message(
          chat_id: mention_bot.chat.telegram_chat_id,
          text: 'Групп нет. Чтобы добавить группу введите /add_group'
        )
      end
    end

    def handle(type, command)
      send("#{type}_handler", command)
    end

    def all_groups
      groups = ::Group.where(chat: mention_bot.chat).order(:id)

      if groups.present?
        {
          text: 'Выберете группу:',
          reply_markup: {
            inline_keyboard: groups.each_slice(2).map do |batch|
              batch.map do |group|
                { text: group.name, callback_data: "groups:#{group.name}" }
              end
            end
          }
        }
      else
        { text: 'Групп нет. Чтобы добавить группу введите /add_group' }
      end
    end

    def groups_handler(command)
      {
        text: "Группа `#{command}`",
        parse_mode: 'Markdown',
        reply_markup: {
          inline_keyboard: [
            [
              { text: 'Изменить', callback_data: "group:#{command}#edit" },
              { text: 'Удалить', callback_data: "group:#{command}#delete" }
            ],
            [{ text: 'Назад', callback_data: 'group:back' }]
          ]
        }
      }
    end

    def group_handler(command)
      return all_groups if command == 'back'

      group, actual_command = command.split('#')

      case actual_command
      when 'edit'
        add_target(group)
        mention_bot.add_context(:edit_group)
        { text: 'Введите новое название группы' }
      when 'delete'
        {
          text: 'Вы уверены?',
          reply_markup: {
            inline_keyboard: [
              [
                { text: 'Да', callback_data: "group:#{group}#destroy" },
                { text: 'Нет', callback_data: "groups:#{group}" }
              ]
            ]
          }
        }
      when 'destroy'
        ::Group.where(chat: mention_bot.chat).find_by!(name: group).destroy!
        { text: "Группа `#{group}` успешно удалена", parse_mode: 'Markdown' }
      end
    rescue ActiveRecord::RecordNotFound => e
      mention_bot.bot.send_message(chat_id: mention_bot.chat.telegram_chat_id, text: 'Группа не найдена')
    rescue ActiveRecord::RecordInvalid => e
      mention_bot.bot.send_message(
        chat_id: mention_bot.chat.telegram_chat_id, text: e.record.errors.full_messages.join("\n")
      )
    end

    def choose_group_handler(command)
      add_target(command)
      mention_bot.add_context(:add_clients)
      {
        text: "Напишите пользователей, которых вы хотите добавить в группу `#{command}` в формате \"@username1 @username2\"",
        parse_mode: 'Markdown'
      }
    end
  end
end
