# frozen_string_literal: true

module CapybaraHelpers
  FIELD_XPATH =
    ".//div[./label[@class='ivu-form-item-label' and normalize-space() = '%<name>s']]" \
    "/div[@class='ivu-form-item-content']//*[contains(@class, 'ivu-input') or " \
    "contains(@class, 'ivu-select') or contains(@class, 'trix-container')]"
  SELECT_ITEM_XPATH =
    %|.//li[contains(@class, 'ivu-select-item') and normalize-space() = "%<value>s"]|
  SELECT_ITEM_CONTAINING_XPATH =
    %|.//li[contains(@class, 'ivu-select-item') and contains(., "%<value>s")][1]|
  DROPDOWN_XPATH =
    %|.//*[@class='ivu-dropdown' and .//*[contains(@class, 'ivu-btn') and normalize-space() = "%<name>s"]]|
  DROPDOWN_ITEM_XPATH =
    %|.//li[contains(@class, 'ivu-dropdown-item') and normalize-space() = "%<value>s"]|

  def ivu_select(node, value)
    node.click

    Array.wrap(value).each do |val|
      option = node.all(:xpath, format(SELECT_ITEM_XPATH, value: val)).first

      if option
        option.click
      else
        node.fill_in(with: val)

        page.driver.wait_for_network_idle

        node.find(:xpath, format(SELECT_ITEM_CONTAINING_XPATH, value: val)).click
      end
    end
  end

  def ivu_fill_field(name, value, click: false)
    field = first(:xpath, format(FIELD_XPATH, name: name))

    case field[:class]
    when /ivu-input/
      field.click if click

      field.fill_in(with: value)
    when /ivu-select/
      ivu_select(field, value)
    when /trix-container/
      field.find('trix-editor').native.send_keys(value)
    else
      raise ArgumentError, 'Unknown field type'
    end
  end

  def ivu_dropdown_click(name, value)
    dropdown = find(:xpath, format(DROPDOWN_XPATH, name: name))

    dropdown.click

    dropdown.find(:xpath, format(DROPDOWN_ITEM_XPATH, value: value)).click
  end
end
