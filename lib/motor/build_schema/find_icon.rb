# frozen_string_literal: true

module Motor
  module FindIcon
    ICONS_MAP = {
      'audit' => 'history',
      'block' => 'ban',
      'blocked' => 'ban',
      'blacklisted' => 'ban',
      'blocklisted' => 'ban',
      'banned' => 'ban',
      'website' => 'world',
      'location' => 'gps',
      'photo' => 'photo',
      'image' => 'photo',
      'screenshot' => 'photo',
      'picture' => 'photo',
      'video' => 'video',
      'file' => 'file',
      'pdf' => 'file-text',
      'ad' => 'ad',
      'shop' => 'building-store',
      'store' => 'building-store',
      'seller' => 'building-store',
      'app' => 'apps',
      'book' => 'book',
      'movie' => 'movie',
      'country' => 'map',
      'api' => 'tool',
      'config' => 'tool',
      'key' => 'key',
      'phone' => 'phone',
      'call' => 'phone',
      'cell' => 'phone',
      'token' => 'key',
      'secret' => 'lock',
      'automation' => 'manual-gearbox',
      'workflow' => 'manual-gearbox',
      'relationship' => 'hierarchy',
      'person' => 'user',
      'people' => 'users',
      'mail' => 'mail',
      'user' => 'user',
      'rating' => 'star',
      'article' => 'blockquote',
      'podcast' => 'headphones',
      'payment' => 'cash',
      'log' => 'history',
      'history' => 'history',
      'rule' => 'manual-gearbox',
      'tracking' => 'zoom-question',
      'github' => 'brand-github',
      'tag' => 'hash',
      'category' => 'hash',
      'label' => 'hash',
      'twitter' => 'brand-twitter',
      'facebook' => 'brand-facebook',
      'google' => 'brand-google',
      'renewal' => 'repeat',
      'sales' => 'report-money',
      'telegram' => 'brand-telegram',
      'whatsapp' => 'brand-whatsapp',
      'survey' => 'checkbox',
      'subcategory' => 'hash',
      'type' => 'hash',
      'model' => 'hash',
      'taxon' => 'hash',
      'affiliate' => 'affiliate',
      'chat' => 'message-circle',
      'message' => 'messages',
      'poll' => 'messages',
      'feedpack' => 'messages',
      'attachment' => 'paperclip',
      'certificate' => 'certificate',
      'approval' => 'certificate',
      'bank' => 'building-bank',
      'bridge' => 'building-bridge',
      'car' => 'car',
      'vehicle' => 'car',
      'analytic' => 'device-analytics',
      'stat' => 'device-analytics',
      'statistic' => 'device-analytics',
      'link' => 'link',
      'slug' => 'link',
      'city' => 'building-skyscraper',
      'region' => 'map',
      'district' => 'building-community',
      'community' => 'building-community',
      'activity' => 'activity',
      'invoice' => 'file-invoice',
      'settlement' => 'file-invoice',
      'state' => 'map',
      'note' => 'note',
      'order' => 'truck-delivery',
      'lead' => 'building-lighthouse',
      'error' => 'file-alert',
      'page' => 'brand-pagekit',
      'date' => 'calendar-event',
      'customer' => 'users',
      'client' => 'users',
      'ticket' => 'ticket',
      'contact' => 'users',
      'member' => 'users',
      'admin' => 'user-check',
      'notification' => 'bell',
      'alert' => 'bell',
      'team' => 'users',
      'folder' => 'folder',
      'subscriber' => 'user-plus',
      'product' => 'building-store',
      'html' => 'code',
      'stripe' => 'brand-stripe',
      'email' => 'mail',
      'status' => 'hash'
    }.freeze

    DEFAULT_ICON = BuildSchema::DEFAULT_ICON

    module_function

    def call(text)
      text = text.underscore
      icon = ICONS_MAP[text] || ICONS_MAP[text.singularize]

      icon ||=
        text.split(%r{[\s_/]}).reverse.reduce(nil) do |_acc, word|
          found_icon = ICONS_MAP[word] || ICONS_MAP[word.singularize]

          break found_icon if found_icon
        end

      icon || DEFAULT_ICON
    end
  end
end
