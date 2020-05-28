extends Control

# GET /repos/:owner/:repo/git/trees/:tree_sha
var usr := "rakugoteam"
var repo := "rakugo"
var url := "https://api.github.com/repos/{usr}/{repo}/git/trees/master?recursive=1"
var request := ""
var download := false
var files := {}
var id := 0

func _on_DownloadButton_pressed():
	request = url.replace("{usr}", usr).replace("{repo}", repo)
	print(request)
	$HTTPRequest.request(request)


func get_files_list(body):
	var json := JSON.parse(body.get_string_from_utf8())

	for f in json.result["tree"]:
		files[f["path"]] = f["url"]
	
	print(files.keys()[0])


func dowload_file(i : int):
	var path = files.keys()[i]
	var file_url = files.values()[i]
	$HTTPRequest.download_file = path
	$HTTPRequest.request(file_url) 


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if not download:
		get_files_list(body)
		download = true
		id = 0
		dowload_file(id)
		return
	
#	if id < 2:
#		id += 1
#		dowload_file(id)
	
	
	
