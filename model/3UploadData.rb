require 'gooddata'
require 'yaml'

credential = YAML.load_file 'credential.yml'

project_id = YAML.load_file 'project_id.yml'

GoodData.with_connection(credential['gooddata_user'], credential['gooddata_password']) do |client|
  	
  	project = GoodData.use(project_id['project_id'])
  	blueprint = project.blueprint

	GoodData::Model.upload_data("projects.csv", blueprint, "project")
	GoodData::Model.upload_data("testsuites.csv", blueprint, "test_suite")
	GoodData::Model.upload_data("testcases.csv", blueprint, "test_case")
	GoodData::Model.upload_data("events.csv", blueprint, "event")

end