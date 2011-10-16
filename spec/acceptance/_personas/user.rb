module Test
  class User

    attr_accessor :rspec_world
    attr_accessor :user
    attr_accessor :password

    DEFAULT_AREA = '#main'

    LOCALE = {:en => "en-GB", :no => "no-NB"}

    def initialize(rspec_world, options = {}, autologin = true)
      @rspec_world = rspec_world
      #self.user = create_user(options)
      #yield(self) if block_given?
      #after_create
      #log_me_in if autologin
      #self
    end

    def has_role(*roles)
      roles.each do |role|
        user.has_role!(role)
      end
    end

    alias_method :has_roles, :has_role

    # TODO improve - progressive method missing with learning module cache pattern
    def method_missing(sym, *args, &block)
      if rspec_world.respond_to?(sym)
        rspec_world.send(sym, *args)
      else
        super
      end
    end

    # TODO extract to module

    LOOK_LIKE_TRANSLATION_KEY = /^[^\d]\S+\.(\S+\.?)+$/
    EMAIL = /([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})/i
    FILE = /\A\w+\.(xls|doc|jpg)\z/i

    def click_confirmation_popup(value)
      result = value.downcase == "ok" ? true : false
      rspec_world.page.evaluate_script("window.confirm = function() { return #{result}; }")
    end

    def click(link_text, options={:within => DEFAULT_AREA})
      yield if block_given?
      rspec_world.within(options[:within]) do
        begin
          rspec_world.click_on(self_or_translation_for(link_text))
        rescue Capybara::ElementNotFound => e
          attr_value, attr_type = within_value_and_type(options[:within])
          xpath = attr_type ? "//*[@#{attr_type}='#{attr_value}']//*[*='%s']/*" : "//*[#{attr_type}]//*[*='%s']/*"
          rspec_world.find(:xpath, xpath % self_or_translation_for(link_text)).click
        end
      end
    end

    def go_back
      rspec_world.page.evaluate_script('window.history.back()')
    end

    def click_within area
      yield if block_given?
      rspec_world.find(area).find('a').click
    end

    def click_within_line_with_text(with_text, link_text)
      yield if block_given?
      xpath = ".//*[@id='main']//*[*='%s']"
      rspec_world.within(:xpath, xpath % with_text) do
        rspec_world.click_on(self_or_translation_for(link_text))
      end
    end

    def click_image(alt)
      yield if block_given?
      rspec_world.find("img[alt='#{self_or_translation_for(alt)}']").click
    end

    def count_elements within_seach, tag, number = 0
      attr_value, attr_type = within_value_and_type(within_seach)
      xpath = "//*[@id='main']//*[@#{attr_type}='#{attr_value}']//*[count(#{tag})=#{number}]"
      rspec_world.find(:xpath, xpath)
    end

    def hover_mouse_on(element_id)
      rspec_world.page.driver.execute_script("$('#{element_id}').trigger('mouseover');")
    end

    def js_populate_form(hash)
      hash.each_pair do |id, value|
        rspec_world.page.driver.execute_script("$('#{id}').val('#{value}');")
      end
    end

    def js_click id
      hover_mouse_on(id)
      rspec_world.page.driver.execute_script("$('#{id}').click();")
    end

    def populate_ckeditor name, value
      rspec_world.page.driver.execute_script "CKEDITOR.instances['#{name}'].setData('#{value}');"
    end

    def remove_ckeditor_instances
      execute_js "$('textarea').ckeditor(function(){ this.destroy(); });"
    end

    def execute_js code
      rspec_world.page.driver.execute_script code
    end

    def go_homepage
      visit '/'
    end

    def goto url
      visit url
    end

    def switch_locale locale
      lang = LOCALE[locale]
      lang ? (visit("#{rspec_world.page.current_path}?locale=#{lang}") and I18n.locale = lang) : throw("Unknown locals #{locale}")
    end

    def reload_page
      visit rspec_world.page.current_path
    end

    def see(*something)
      something.each do |sth|
        if sth.is_a?(Hash)
          sth.each_pair do |_id, _value|
            if _value.is_a? Regexp
              rspec_world.find_field(self_or_translation_for(_id)).value.should match _value
            elsif _value.is_a? Symbol
              rspec_world.find_field(self_or_translation_for(_id)).value.send(_value).should == true
            else
              _node = rspec_world.find_field(self_or_translation_for(_id))
              case _node.tag_name
                when 'input'
                  case _node[:type]
                    when 'text', 'password'
                      rspec_world.find_field(self_or_translation_for(_id)).value.should == _value
                    when 'checkbox'
                      if _value
                        rspec_world.find_field(self_or_translation_for(_id))[:checked].to_s.should == _value.to_s
                      else
                        rspec_world.find_field(self_or_translation_for(_id))[:checked].to_s.should_not == !_value.to_s
                      end
                    else
                      throw "type not implemented #{_node.tag_name} :: #{_node[:type]}"
                  end
                when 'textarea'
                  rspec_world.find_field(self_or_translation_for(_id)).value.should == _value
                when 'select'
                  throw "tag name is not supported #{_node.tag_name}"
                else
                  throw "tag name is not supported #{_node.tag_name}"
              end
            end
          end
        else
          if sth.is_a? Regexp
            rspec_world.page.body.should match sth
          else
            rspec_world.page.should rspec_world.have_content(self_or_translation_for(sth))
          end
        end
      end
    end

    def see_within(within = DEFAULT_AREA, *argv)
      rspec_world.within(within) do
        see(*argv)
      end
    end

    def see_for(text, *argv)
      xpath = ".//*[@id='main']//*[*='%s']"
      rspec_world.within(:xpath, xpath % text) do
        see(*argv)
      end
    end

    def see_field_within(field, value)
      rspec_world.find_field(self_or_translation_for(field)).value.should == value
    end

    def not_see_field_within(field, value)
      rspec_world.find_field(self_or_translation_for(field)).value.should_not == value
    end

    def see_elements_sorted(matcher, *elements)
      rspec_world.all(matcher).map { |node| node.text.strip }.should == elements
    end

    def not_see(*something)
      something.each do |sth|
        rspec_world.page.should_not rspec_world.have_content(self_or_translation_for(sth))
      end
    end

    def see_disabled_element(*elements)
      elements.each do |element|
        rspec_world.page.driver.evaluate_script("$('#{element}').attr('disabled')").should == true
      end
    end

    def see_link_to link_text, type, link
      xpath = ".//*[@id='main']//*[*='%s']"
      rspec_world.within(:xpath, xpath % link_text) do
        page.find_link(self_or_translation_for(type))[:href].should == "#{link}#{link_text}"
      end
    end

    def not_see_within(within = DEFAULT_AREA, *argv)
      rspec_world.within(within) do
        not_see(*argv)
      end
    end

    def compares value_1, value_2, compare_type = :equal?, compare_result = true
      if value_1.respond_to?(compare_type)
        value_1.send(compare_type, value_2).should == compare_result
      else
        throw "Unknown compare Rspec method for #{value_1} :: #{value_1.class}"
      end
    end

    def find object
      rspec_world.find(object).first
    end

    def move_object object_from, object_to
      object_from.drag_to object_to
    end

    def populate_form(hash, xpath = nil)
      hash.each_pair do |_id, _value|

        _node, _within = unless xpath
                           [rspec_world.find_field(self_or_translation_for(_id)), lambda { | &blk | rspec_world.within('body') { blk.call } }]
                         else
                           rspec_world.within(:xpath, xpath) do
                             [rspec_world.find_field(self_or_translation_for(_id)), lambda { | &blk | rspec_world.within(:xpath, xpath) { blk.call } }]
                           end
                         end

        _within.call do
          case _node.tag_name
            when 'input'
              case _node[:type]
                when 'text', 'password', 'email'
                  rspec_world.fill_in self_or_translation_for(_id), :with => _value
                when 'checkbox'
                  _value ? rspec_world.check(self_or_translation_for(_id)) : rspec_world.uncheck(self_or_translation_for(_id))
                when 'radio'
                  _value ? rspec_world.choose(_id) : nil
                when 'file'
                  rspec_world.attach_file(_id, _value)
                else
                  throw "type not implemented #{_node.tag_name} :: #{_node[:type]}"
              end
            when 'textarea'
              rspec_world.fill_in self_or_translation_for(_id), :with => _value
            when 'select'
              rspec_world.select(self_or_translation_for(_value), :from => self_or_translation_for(_id))
            else
              throw "tag name is not supported #{_node.tag_name}"
          end
        end
        #        case detect_field_type(rspec_world.find_field(self_or_translation_for(_id)))
        #
        #        end
        #        rspec_world.fill_in self_or_translation_for(_id), :with => _value
      end
    end

    def see?(_id)
      rspec_world.find(self_or_translation_for(_id)).visible?
    end

    def wait_until
      raise NonBlockGiven unless block_given?
      rspec_world.wait_until { yield }
    end

    def read_email(mail, *args)
      args.first.each_pair do |k, v|
        throw "#{mail.class} doesn't respond to #{k.to_sym}" unless mail.respond_to?(k.to_sym)
        mail.send(k.to_sym).raw_source.should include v
      end
    end

    def search_text_which_match_to regexp
      rspec_world.page.body.to_s[regexp]
    end


    private

    def within_value_and_type within
      within_value = within.gsub(/#|\./, "")
      within_type = case within
                      when /^\#/ then
                        "id"
                      when /^\./ then
                        "class"
                      else
                        "id"
                    end
      [within_value, within_type]
    end

    def self_or_translation_for(string)
      # TODO use better regex for email address
      if (string =~ LOOK_LIKE_TRANSLATION_KEY and string !~ EMAIL and string !~ FILE)
        string = (translations_hash = rspec_world.translations_map).present? ? (translations_hash[string] || string) : string
        I18n.t(string, :locale => I18n.locale)
      else
        string
      end
    end

    # end of module

    def create_user(options={})
      self.password= options[:password] || 'Secret99'
      confirm = options.delete(:confirm)
      _u = ::User.create!(user_create_options.merge(options.merge({
                                                                      :password => password,
                                                                      :password_confirmation => password,
                                                                      :pagination_size => 10,
                                                                      :eula_accepted => 2})))
      _u.confirm! if confirm or confirm.nil?
      _u.save
      _u
    end

    def log_me_in
      visit "/?locale=#{I18n.locale}"
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => password
      click_on "user_submit"
    end

    # stub
    def user_create_options
      {}
    end

    def after_create
      # stub
    end
  end
end
