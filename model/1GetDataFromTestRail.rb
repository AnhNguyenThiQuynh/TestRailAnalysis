require 'testrail'
require 'json'
require 'csv'
require 'time'
require 'date'
require 'yaml'

client = TestRail::APIClient.new('https://gooddata.testrail.com')
credential = YAML.load_file 'credential.yml'
client.user = credential['testrail_user']
client.password = credential['testrail_password']

input = YAML.load_file 'input.yml'

projects = Array.new
testsuite_table = Hash.new (0)
milestone_table = Hash.new (0)

testParams = input['projects']
testParams.each do |testParam|
	projects.push client.send_get "get_project/#{testParam['projectId']}"
	testsuite_table[testParam['projectId']] = testParam['testsuiteId']
	milestoneList = client.send_get "get_milestones/#{testParam['projectId']}"
	milestoneList.each do |milestone|
		milestone_table["#{milestone['id']}"] = "#{milestone['name']}"
	end
end

CSV.open("projects.csv", "wb") do |csv_project|
	CSV.open("testsuites.csv", "wb") do |csv_testsuite|
		CSV.open("testcases.csv", "wb") do |csv_testcase|
			CSV.open("events.csv", "wb") do |csv_event|
				csv_project << ['project_id','project_name','project_url']
				csv_testsuite << ['suite_id','suite_name','suite_url','project']
				csv_testcase << ['case_id','case_name','case_url','sprint','milestone','is_automated','project','test_suite']
				csv_event << ['case_event_id','event_type','test_case','date_event']
				projects.each do |project|
					csv_project << ["#{project['id']}","#{project['name']}","#{project['url']}"]
					pre_defined_testsuites = testsuite_table[project['id']]
					suites = client.send_get "get_suites/#{project['id']}"
					suites.each do |suite|
						if (pre_defined_testsuites.include?(suite['id'])) then
							csv_testsuite << ["#{suite['id']}","#{suite['name']}","#{suite['url']}","#{project['id']}"]
							cases = client.send_get "get_cases/#{project['id']}&suite_id=#{suite['id']}"
							cases.each do |testcase|
								csv_testcase << ["#{testcase['id']}",
								"#{testcase['title']}",
								"https://gooddata.testrail.com/index.php?/cases/view/#{testcase['id']}",
								"#{testcase['custom_sprint']}",
								milestone_table[testcase['milestone_id']],
								"#{testcase['custom_is_automated']}",
								"#{project['id']}",
								"#{suite['id']}"]
							
								csv_event << ["#{testcase['id']}" + "_CREATED",
								"CREATED",
								"#{testcase['id']}",
								Time.at(testcase['created_on']).utc.strftime("%d/%m/%Y")]

								if (!testcase['custom_automated_on'].nil?) then 
									csv_event << ["#{testcase['id']}" + "_AUTOMATED",
									"AUTOMATED",
									"#{testcase['id']}",
									Date.strptime(testcase['custom_automated_on'],"%m/%d/%Y").strftime("%d/%m/%Y")]
								elsif (testcase['custom_is_automated']) then
									csv_event << ["#{testcase['id']}" + "_AUTOMATED",
									"AUTOMATED",
									"#{testcase['id']}",
									Time.now.strftime("%d/%m/%Y")]
								end
							end
						end
					end
				end						
			end
		end
	end
end

