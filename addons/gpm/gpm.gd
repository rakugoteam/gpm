extends Control

# GET /repos/:owner/:repo/git/trees/:tree_sha
var _github_request := "https://api.github.com/repos/{usr}/{repo}/git/trees/master?recursive=1"
var test_manifest = "rakugo.json"
var request := ""
var download := false
var files := {}
var paths := []
var id := 0

var test_url = "https://github.com/rakugoteam/Rakugo"
var directory := Directory.new()


func get_github_request(url:String) -> String:

	if not ("github.com" in url):
		prints(url, "is not corret github url aborting")
		return ""

	var splited_url = url.split("/", false)
	var usr = splited_url[2]
	var repo = splited_url[3]

	return _github_request.replace("{usr}", usr).replace("{repo}", repo)


func _on_DownloadButton_pressed():
	request = get_github_request(test_url)
	$HTTPRequest.request(request)


func get_files_list(body, paths):
	var json := JSON.parse(body.get_string_from_utf8())
	
	print(json.result["message"])
	
	for f in json.result["tree"]:
		if is_path_in(f.path, paths):
			files[f.path] = f.url


func get_manifest_paths(path:String) -> Array:
	var f := File.new()
	f.open(path, File.READ)
	var body = f.get_as_text()
	f.close()

	var json := JSON.parse(body)
	var xpaths := []

	var packages = json.result["packages"]
	for package_id in packages:
		xpaths.append(packages[package_id].path)
		prints("Found package:", package_id)

	return xpaths


func download_file(i : int, paths:Array):
	var path = "res://" + files.keys()[i]
	var file_url = files.values()[i]
	
	var dir = path.get_base_dir()
	if not directory.dir_exists(dir):
		directory.make_dir_recursive(dir)
	
	$HTTPRequest.download_file = path
	$HTTPRequest.request(file_url)
	prints("download file:", path)

func is_path_in(path:String, paths:Array) -> bool:
	var result = false

	for p in paths:
		result = result or (p in path)

	return result


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if not download:
		download = true
		files = {}
		id = 0
		paths = get_manifest_paths(test_manifest)
		get_files_list(body, paths)
		print(files)

	download_next_file()

func download_next_file():
	
	if id < files.size():
		download_file(id, paths)
		id += 1
		return

	print("finished")
