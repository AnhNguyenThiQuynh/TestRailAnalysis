require 'gooddata'
require 'yaml'

credential = YAML.load_file 'credential.yml'

project_id = YAML.load_file 'project_id.yml'

GoodData.with_connection(credential['testrail_user'], credential['testrail_password']) do |client|

	project = GoodData.use(project_id['project_id'])
  	blueprint = project.blueprint

	project_dataset = blueprint.find_dataset("project")
	test_suite_dataset = blueprint.find_dataset("test_suite")
	test_case_dataset = blueprint.find_dataset("test_case")
	event_dataset = blueprint.find_dataset("event")

	GoodData::Model.upload_data('projects.csv', blueprint, project_dataset)
	GoodData::Model.upload_data('testsuites.csv', blueprint, test_suite_dataset)
	GoodData::Model.upload_data('testcases.csv', blueprint, test_case_dataset)
	GoodData::Model.upload_data('events.csv', blueprint, event_dataset)

end