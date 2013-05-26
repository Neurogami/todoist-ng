require 'open-uri'
require 'cgi'
require 'json'
require 'pp'

module Neurogami
  module Todoist

    class Project

      include Constants

      @@token = 'NO_TOKEN!'
      @@labels  = nil
      @@projects = nil

      attr_accessor	:name, :id, :item_order, :cache_count, :color, :user_id, :items

      def self.token= t
        @@token = t
      end
      def self.token
        @@token 
      end

      def initialize details 
        details.each { |k,v|  eval "@#{k} = '#{v}'"}
        @items = nil
      end

      def uncompleted_items
        # http://todoist.com/API/getUncompletedItems?project_id=22073&token=fb5f22601ec566e48083213f7573e908a7a272e5 
        begin
          items = JSON.parse(open( "#{BASE_URL}/getUncompletedItems?project_id=#{id};token=#{@@token}").read)
          items.map {|i| Item.new(i)}
        rescue Exception => e
          STDERR.puts " \n ERROR at #{__FILE__}:#{__LINE__}: Error getting uncompleted_items.\n #{e.inspect} "
          raise e
        end
      end


      def items reload=false
        return @items if @items && !reload
        @items = completed_items
        @items.concat(uncompleted_items)
        @items 
      end

      def completed_items offset = 0
        #Get completed items
        #A request is sent to getCompletedItems with project_id and optionally an offset:
        #http://todoist.com/API/getCompletedItems?project_id=22073&offset=0&token=fb5f22601ec566e48083213f7573e908a7a272e5 
        begin
          items = JSON.parse(open( "#{BASE_URL}/getCompletedItems?project_id=#{id};offset=#{offset};token=#{@@token}").read)
          items.map {|i| Item.new(i)}
        rescue Exception => e
          STDERR.puts " \n ERROR at #{__FILE__}:#{__LINE__}: Error getting completed_items\n #{e.inspect} "
          raise e
        end

      end

      def update_item item_id, content
        #        Update item
        #A request is sent to updateItem with id, content and optionally a date_string, priority (int value from 1 to 4):
        #http://todoist.com/API/updateItem?id=210873&content=TestHello&token=fb5f22601ec566e48083213f7573e908a7a272e5 
        begin
          JSON.parse(open( "#{BASE_URL}/updateItem?id=#{item_id};'content=#{content};token=#{@@token}").read)
        rescue Exception => e
          STDERR.puts " \n ERROR at #{__FILE__}:#{__LINE__}: Error calling update_item\n #{e.inspect} "
          raise e
        end
      end


      def add_item content, attributes = { :date_string => 'tomorrow', :priority => 2 }

        #    Add an item to a project
        #A request is sent to addItem with project_id, content and optionally date_string, priority (int value from 1 to 4):
        #http://todoist.com/API/addItem?content=Test&project_id=22073&priority=1&token=XXXXX22601ec56XXXX8083213fXXXXXX08a7a272e5
        #JSON data is returned:
        #{"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 0, "priority": 1, "item_order": 5, "faded": 0, "content": "Test", "indent": 1, "project_id": 22073, "id": 210873, "checked": 0, "date_string": null}
        content.strip!

        raise "Cannot add an empty item!" if content.empty?
        if attributes[:labels]
          attributes[:labels]  =  attributes[:labels].split(',').map{ |l| " @#{l.strip}"}.join( ' ' )
          content <<  attributes[:labels]
          attributes.delete(:labels)
        end
        content = CGI.escape(content)
        attr_set = []
        attributes.each {|k,v| attr_set << "#{k.to_s}=#{CGI.escape(v.to_s.strip)}" }  

        attr_set = attr_set.join(';')
        attr_set.strip!
        attr_set  = ";#{attr_set}" unless attr_set.empty? 
        url = "#{BASE_URL}/addItem?project_id=#{self.id};token=#{@@token};content=#{content}#{attr_set}"
        url.sub!( /\+$/, '' )
        
        # warn "Add to project:\n#{url}"

        JSON.parse open(url).read
      end



      def delete_item item_id
        #        Delete an item
        #A request is sent to deleteItems with items ids and project_id.

        begin
          JSON.parse(open( "#{BASE_URL}/deleteItem?id=#{item_id};token=#{@@token}").read)
        rescue Exception => e
          STDERR.puts " \n ERROR at #{__FILE__}:#{__LINE__}: Error calling delete_item\n #{e.inspect} "
          raise e
        end

      end

      def self.project_named name
        projects.each do |prj|
          return prj if prj.name == name
        end
        nil
      end

      def self.get_projects reload=false
        return @@projects if @@projects && !reload
        begin
          projects = open( "#{BASE_URL}/getProjects?token=#{@@token}").read 
          # warn  projects
          results = JSON.parse projects
        rescue Exception => e
          STDERR.puts " \n ERROR at #{__FILE__}:#{__LINE__}: Error getting projects using url '#{BASE_URL}/getProjects?token=#{@@token}'\n #{e.inspect} "
          raise e
        end
        @@projects = results.map {|pr| Project.new(pr)} 
      end

      def self.projects(reload=false); get_projects(reload); end

      def self.get_project project_id
        result = JSON.parse(open( "#{BASE_URL}/getProject?project_id=#{project_id};token=#{@@token}").read)
        Project.new result 
      end

      def self.project(project_id); get_project(project_id); end

      def self.labels reload = false
        # http://todoist.com/API/getLabels?token=fb5f22601ec566e48083213f7573e908a7a272e5
        return @@labels if @@labels && !reload
        @@labels = JSON.parse(open( "#{BASE_URL}/getLabels?token=#{@@token}").read)
      end

      def self.label_from_id id
        # The todoist returns labels as a hash, where the key is a string that points
        # to another hash, and that other hash has a ID.
        # When you get an Item, and ask for its labels, you get that ID instead
        # of a simple string. :(
        # So, this method gets you the label info for that ID
        self.labels.each do |k, v|
          return v if v['id'].to_i == id.to_i
        end
        nil
      end


      def self.add_item_to_project project_name, content, attributes = { :date_string => 'tomorrow @ 8am', :priority => 2 }
        project = project_named(project_name)
        project.add_item content, attributes
      end

    end

  end
end

__END__
https://todoist.com/API/help

Introduction
Todoist API can be used to hook Todoist into other applications. The API is work in progress and functionality will be added as people request it. So if you want some functionality, don't hesitate to contact me.
  Authentication
Every Todoist user has a special web service token, which can be found on the Preferences page. This token is used for authentication. The token represents the password, so don't distribute it, that would be like giving the password away.
  Solving cross domain security policy
You can't use AJAX to directly communicate with Todoist, this is due to browser security policy. You can solve this by communicating with Todoist using a script tag:
  var script = document.createElement('script');
script.type = 'text/javascript';
script.src = 'http://todoist.com/API/...&callback=callbackFunction';
document.getElementsByTagName('head')[0].appendChild(script);
The response data will look like this:
  callbackFunction({ JSON data here });
I.e. callbackFunction will be called.
  Projects and labels [top]
Get all projects
A request is sent to getProjects:
  http://todoist.com/API/getProjects?token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  [{"user_id": 1, "name": "Test project", "color": 1, "collapsed": 0, "item_order": 1, "indent": 1, "cache_count": 4, "id": 22073},
    {"user_id": 1, "name": "Another test project", "color": 2, "collapsed": 0, "item_order": 2, "indent": 1, "cache_count": 0, "id": 22074},
    ...]
Get project
A request is sent to getProject with project_id:
  http://todoist.com/API/getProject?project_id=22073&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  {"user_id": 1L, "name": "Test project", "color": 1L, "collapsed": 0L, "item_order": 1L, "indent": 1L, "cache_count": 4L, "id": 22073L}
Get all labels
A request is sent to getLabels:
  http://todoist.com/API/getLabels?token=fb5f22601ec566e48083213f7573e908a7a272e5
Items [top]
Get uncompleted items
A request is sent to getCompletedItems with project_id:
  http://todoist.com/API/getUncompletedItems?project_id=22073&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  [{"due_date": new Date("Sun Apr 29 23:59:59 2007"), "user_id": 1, "collapsed": 0, "in_history": 0, "priority": 1, "item_order": 1, "faded": 0, "content": "By these things", "indent": 1, "project_id": 22073, "id": 210870, "checked": 0, "date_string": "29. Apr 2007"},
    {"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 0, "priority": 1, "item_order": 2, "faded": 0, "content": "Milk", "indent": 2, "project_id": 22073, "id": 210867, "checked": 0, "date_string": ""},
    ...]
Get completed items
A request is sent to getCompletedItems with project_id and optionally an offset:
  http://todoist.com/API/getCompletedItems?project_id=22073&offset=0&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  [{"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 1, "priority": 1, "item_order": 2, "faded": 0, "content": "Fluffy ferret", "indent": 1, "project_id": 22073, "id": 210872, "checked": 1, "date_string": ""},
    {"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 1, "priority": 1, "item_order": 1, "faded": 0, "content": "Test", "indent": 1, "project_id": 22073, "id": 210871, "checked": 1, "date_string": ""}
...]
Add an item to a project
A request is sent to addItem with project_id, content and optionally date_string, priority (int value from 1 to 4):
  http://todoist.com/API/addItem?content=Test&project_id=22073&priority=1&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  {"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 0, "priority": 1, "item_order": 5, "faded": 0, "content": "Test", "indent": 1, "project_id": 22073, "id": 210873, "checked": 0, "date_string": null}
Update item
A request is sent to updateItem with id, content and optionally a date_string, priority (int value from 1 to 4):
  http://todoist.com/API/updateItem?id=210873&content=TestHello&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data of the item is returned:
  {"due_date": null, "user_id": 1, "collapsed": 0, "in_history": 0, "priority": 1, "item_order": 5, "faded": 0, "content": "TestHello", "indent": 1, "project_id": 22073, "id": 210873, "checked": 0, "date_string": null}
Delete an item
A request is sent to deleteItems with items ids and project_id.
  Move items to the history
A request is sent to completeItems with item ids.
  http://todoist.com/API/completeItems?ids=[210873, 210873]&token=fb5f22601ec566e48083213f7573e908a7a272e5
Get items by id
A request is sent to getItemsById with item ids.
  http://todoist.com/API/getItemsById?ids=[210873, 210873]&token=fb5f22601ec566e48083213f7573e908a7a272e5
Query [top]
Queries
A request is sent to query with:

  * queries: A JSON string list of queries. Date format is 2007-4-29T10:59. Following queries are supported: viewall, overdue, p1, p2, p3

Example:
  http://todoist.com/API/query?queries=["2007-4-29T10:13","overdue","p1","p2"]&token=fb5f22601ec566e48083213f7573e908a7a272e5
JSON data is returned:
  [{"type": "date", "query": "2007-4-29T10:13", "data": [[...]]},
    {"type": "overdue", "data": [...]}, ...],

