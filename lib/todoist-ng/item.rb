require 'pp'

module Neurogami
  module Todoist

    # May want an Item class at some point ...
    class Item

      include Constants
=begin
 {"checked"=>0,
  "project_id"=>511874,
  "collapsed"=>0,
  "date_string"=>"mon",
  "priority"=>3,
  "id"=>3991694,
  "indent"=>1,
  "is_dst"=>0,
  "item_order"=>4,
  "chains"=>nil,
  "mm_offset"=>-420,
  "content"=>"test1232867261",
  "has_notifications"=>0,
  "due_date"=>"Mon Jan 26 23:59:59 2009",
  "in_history"=>0,
  "user_id"=>95496,
  "children"=>nil,
  "labels"=>[58599, 58593]},
=end
      attr_accessor :checked, :project_id, :collapsed, :date_string, :priority, :id, :indent, :is_dst
      attr_accessor :item_order, :chains, :mm_offset, :content, :has_notifications 
      attr_accessor :due_date, :in_history, :user_id, :children, :labels

      def initialize details
        details.each do |k,v|  
          # 'children' might be special as well ...
          next if k == 'labels'
          eval "@#{k} = '#{v}'"
        end

        @labels = details['labels'] # How do we want to work with these?
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


