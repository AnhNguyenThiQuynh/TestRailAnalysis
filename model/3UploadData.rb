require 'gooddata'
require 'yaml'

credential = YAML.load_file 'credential.yml'

GoodData.with_connection(credential['testrail_user'], credential['testrail_password']) do |client|

	# blueprint = eval(File.read("2CreateLDM.rb")).to_blueprint

	project = GoodData.use('pms3whnxecvs3geprcwcwqd465fv771m')
  	blueprint = project.blueprint

	project = blueprint.find_dataset("project")
	test_suite = blueprint.find_dataset("test_suite")
	test_case = blueprint.find_dataset("test_case")
	test_case = blueprint.find_dataset("event")


	project = GoodData::Model.upload_data('projects.csv', blueprint, "project")
	test_suite = GoodData::Model.upload_data('testsuites.csv', blueprint, "test_suite")
	test_case = GoodData::Model.upload_data('testcases.csv', blueprint, "test_case")
	test_case = GoodData::Model.upload_data('events.csv', blueprint, "test_case")

end