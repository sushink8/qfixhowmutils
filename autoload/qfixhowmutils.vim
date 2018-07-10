
function! qfixhowmutils#countInDir(dir,displayfunction)
	let files = split(glob(a:dir."/*"),"\n")
	let ret = []
	for l:filepath in l:files
		if !filereadable(l:filepath)
			continue
		endif
		echo l:filepath a:displayfunction(qfixhowmutils#listProgress(readfile(l:filepath)))
		let ret += [ l:filepath . " " . a:displayfunction(qfixhowmutils#listProgress(readfile(l:filepath))) ]
	endfor
	return ret
endfunction

function! qfixhowmutils#showProgress(dir,displayfunction,file,hiddencomplete)
	let l:qflist = qfixlist#grep("{.}",a:dir,a:file)
	let l:files = {}
	let l:qflist2 = []
	for i in l:qflist
		let files[i.filename] = ""
	endfor
	for fpath in keys(l:files)
		let l:path = fnamemodify(fpath,":p")
		if !filereadable(l:path)
			continue
		endif
		let [l:comp,l:all] = qfixhowmutils#listProgress(readfile(l:path))
		if a:hiddencomplete && l:comp == l:all
			continue	
		endif
		let result = a:displayfunction([l:comp,l:all])
		call add(l:qflist2,{'filename':fpath,'lnum':1,'text':result})
	endfor
	call qfixlist#copen(l:qflist2,g:qfixmemo_dir)
endfunction



function! qfixhowmutils#percentageTodo(progress)
	let l:comp = a:progress[0]
	let l:all = a:progress[1]
	if l:all <= 0
		return "0%"
	endif
	return printf("%.1f%%",(l:comp * 1.0) / (l:all * 1.0) * 100 )
endfunction

function! qfixhowmutils#countTodo(progress)
	let l:comp = a:progress[0]
	let l:all = a:progress[1]
	return printf("%d/%d",l:comp,l:all)
endfunction

function! qfixhowmutils#countRegexCurrentFile(regex)
	return qfixhowmutils#countRegex(getline(0,"$"),a:regex)
endfunction


function! qfixhowmutils#countRegex(lines,regex)
	let l:c = 0
	for line in a:lines
		if match(line,a:regex) >= 0
			let l:c = l:c + 1
		endif
	endfor
	return l:c
endfunction

function! qfixhowmutils#buildHowmDiaryFilePath(time)
	return strftime("howm://" . g:QFixHowm_DiaryFile ,a:time)
endfunction

function! qfixhowmutils#howmFilePath(filepath)
	let l:filepath = substitute(expand(a:filepath.":p"),'\\','/','g')
	let l:expanded_howm_dir = substitute(expand(g:howm_dir),'\\','/','g')
	return substitute(l:filepath,l:expanded_howm_dir,"howm:/",'g')
endfunction

function! qfixhowmutils#buildTimeFromFileName(filename)
	try
		let [l:year,l:month,l:date,_] = split(expand(a:filename.":t:r"),"-")
	catch //
		return ""
	endtry
	if l:date == "00"
		let l:date = "01"
	endif
	return datelib#StrftimeCnvDoWShift(l:year,l:month,l:date,"",0)
endfunction

function! qfixhowmutils#buildMonthlyFilePath(time)
	return strftime(g:howm_dir . "/%Y/%m/%Y-%m-00-000000.txt",a:time)
endfunction

function! qfixhowmutils#shiftDate(t,n)
	return a:t + a:n * 86400	
endfunction

function! qfixhowmutils#listProgress(lines)
	let lines = a:lines
	let l:count_all_list = qfixhowmutils#countRegex(lines,'^\s*[-*]\?\s*{.}\|{.}\s*$')
	let l:count_complete_list = qfixhowmutils#countRegex(lines,'^\s*[-*]\?\s*{[^ ]}\|{[^ ]}\s*$')
	return [l:count_complete_list , l:count_all_list]
endfunction

function! qfixhowmutils#bufopen(path)
	let path = a:path
	silent! execute ':args ' . path
endfunction
