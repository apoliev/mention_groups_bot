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
          text: I18n.t('telegram.choose_group_for_add'),
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
          text: I18n.t('telegram.admin_group_not_exist')
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
          text: I18n.t('telegram.choose_group'),
          reply_markup: {
            inline_keyboard: groups.each_slice(2).map do |batch|
              batch.map do |group|
                { text: group.name, callback_data: "groups:#{group.name}" }
              end
            end
          }
        }
      else
        { text: I18n.t('telegram.admin_group_not_exist') }
      end
    end

    def groups_handler(command)
      {
        text: I18n.t('telegram.group', name: command),
        parse_mode: 'Markdown',
        reply_markup: {
          inline_keyboard: [
            [
              { text: I18n.t('telegram.edit'), callback_data: "group:#{command}#edit" },
              { text: I18n.t('telegram.delete'), callback_data: "group:#{command}#delete" }
            ],
            [{ text: I18n.t('telegram.user_list'), callback_data: "group:#{command}#list" }],
            [{ text: I18n.t('telegram.back'), callback_data: 'group:back' }]
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
        { text: I18n.t('telegram.edit_group') }
      when 'delete'
        {
          text: I18n.t('telegram.confirm'),
          reply_markup: {
            inline_keyboard: [
              [
                { text: I18n.t('telegram.t_yes'), callback_data: "group:#{group}#destroy" },
                { text: I18n.t('telegram.t_no'), callback_data: "groups:#{group}" }
              ]
            ]
          }
        }
      when 'destroy'
        ::Group.where(chat: mention_bot.chat).find_by!(name: group).destroy!
        { text: I18n.t('telegram.group_deleted', group_name: group), parse_mode: 'Markdown' }
      when 'list'
        group = ::Group.where(chat: mention_bot.chat).includes(:users).find_by!(name: group)
        msg = group.users.select { |u| u.telegram_username? }.map { |u| "- #{u.telegram_username}" }.join("\n")
        if msg.present?
          { text: msg }
        else
          { text: I18n.t('telegram.users_without_username') }
        end
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
        text: I18n.t('telegram.format_for_add', group_name: command),
        parse_mode: 'Markdown'
      }
    end
  end
end
