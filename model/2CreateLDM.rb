require 'gooddata'
require 'yaml'

credential = YAML.load_file 'credential.yml'

#GoodData.logging_on

GoodData.with_connection(credential['gooddata_user'], credential['gooddata_password']) do |client|
  blueprint = GoodData::Model::ProjectBlueprint.build("TestRail Project") do |p|
    p.add_date_dimension("date_event", :title => "Date (Event)")
    p.add_date_dimension("created_on", :title => "Date (Created)")
    p.add_date_dimension("automated_on", :title => "Date (Automated)")

    p.add_dataset("project") do |d|
      d.add_anchor("project_id", :title => "Project Id")
      d.add_label("project_name", :reference => "project_id", :title => "Project Name")
      d.add_label("project_url", :reference => "project_id", :title => "Project Url")
    end

    p.add_dataset("test_suite") do |d|
      d.add_anchor("suite_id", :title => "Suite Id")
      d.add_label("suite_name", :reference => "suite_id", :title => "Suite Name")
      d.add_label("suite_url", :reference => "suite_id", :title => "Suite Url")
      d.add_reference("project_id", :dataset => "project")
    end

    p.add_dataset("test_case") do |d|
      d.add_anchor("case_id", :title => "Case Id")
      d.add_label("case_name", :reference => "case_id", :title => "Case Name")
      d.add_label("case_url", :reference => "case_id", :title => "Case Url")
      d.add_attribute("sprint", :title => "Sprint")
      d.add_attribute("milestone", :title => "Milestone")
      d.add_attribute("is_automated", :title => "Is Automated")
      d.add_date("created_on", :dataset => "created_on")
      d.add_date("automated_on", :dataset => "automated_on")
      d.add_reference("project_id", :dataset => "project")
      d.add_reference("suite_id", :dataset => "test_suite")
    end

    p.add_dataset("event") do |d|
      d.add_anchor("case_event_id", :title => "Case Event Id")
      d.add_attribute("event_type", :title => "Event Type")
      d.add_reference("case_id", :dataset => "test_case")
      d.add_date("date_event",  :dataset => "date_event" )
    end
  end

  project = GoodData::Project.create_from_blueprint(blueprint, :auth_token => 'INTNA000000GDL2')
  puts "Created project #{project.pid}"

end