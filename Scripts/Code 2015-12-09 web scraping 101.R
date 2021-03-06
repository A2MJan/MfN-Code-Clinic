searchPangaea<-function(query){
	require(XML)
	query <- gsub(" ","+",query)
	q <- TRUE
	offset <- 0
	while(q){
		url_query <- sprintf("https://www.pangaea.de/search?q=%s&count=500&offset=%i", query, offset)
		url_query <- URLencode(url_query)
		page <- htmlParse(readLines(url_query), encoding="UTF-8")
		dataset_name <- xpathSApply(page,"//li/p[@class='citation']/a",xmlValue)
		doi <- xpathSApply(page,"//li/p[@class='citation']/a",xmlAttrs)['href',]
		n <- length(doi)
		if(n<500){q <- FALSE}
		if(!n){stop("No result for that query")}
		if(!offset){
			output <- data.frame(Name=dataset_name, DOI=doi, stringsAsFactors=FALSE)
			}else{
				output <- rbind(output, data.frame(Name=dataset_name, DOI=doi, stringsAsFactors=FALSE))
				}
		offset <- offset + 500
		}
	output
	}
	
getPangaeaData<-function(DOI){		
	require(XML)
	DOI <- as.character(DOI)
	if(grepl("^[0-9]",DOI)) DOI <- paste("http://doi.pangaea.de/",DOI,sep="")
	page <- paste(DOI,"?format=html",sep="")
	html <- htmlParse(page, encoding="UTF-8")
	title <- xpathSApply(html, "//div[@class='MetaHeaderItem']",xmlValue)[1]
	tables <- readHTMLTable(html)
	params <- tables[[length(tables)-1]]
	data <- tables[[length(tables)]]
	list(Citation=title, Parameters=params, Dataset=data)
	}
	