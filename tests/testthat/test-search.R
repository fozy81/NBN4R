context("Test searching functions")

thischeck=function() {
    test_that("search_fulltext generally functions as expected", {
        skip_on_cran()
        expect_that(search_fulltext("Vulpes vulpes"),has_names(c("meta","data")))
        expect_true(all(c("guid","name","commonName","rank","author","occurrenceCount") %in% names(search_fulltext("Vulpes vulpes")$data))) ## "score" and "isAustralian" also used to be present, but are no longer
        expect_that(nrow(search_fulltext("bilbobaggins")$data),equals(0)) ## query that should not match anything
        expect_that(nrow(search_fulltext("red",page_size=20)$data),equals(20))
        expect_that(search_fulltext("Vulpes vulpes",output_format="complete"),has_names(c("meta","data")))
        expect_that(search_fulltext("kingdom:Fungi",output_format="complete"),has_names(c("meta","data")))
        expect_output(print(search_fulltext("Vulpes vulpes")),"Search results:")
        expect_output(print(search_fulltext("Vulpes vulpes",output_format="complete")),"nameFormatted") ## expect extra cols here
    })
}
check_caching(thischeck)

thischeck=function() {
    test_that("search_fulltext start parm works as expected", {
        skip_on_cran()
        x1=search_fulltext("red",page_size=10)
        x2=search_fulltext("red",page_size=10,start=2)
        ## so row 1 of x2$data should equal row 2 of x1$data ... but columns may actually be different!
        temp=intersect(names(x1$data),names(x2$data))
        x1=x1$data[2,c(temp)]
        x2=x2$data[1,c(temp)]
        rownames(x1)=""
        rownames(x2)=""
        expect_equal(x1,x2)
    })
}
check_caching(thischeck)


thischeck=function() {
    test_that("search_fulltext sort_by parm works as expected", {
        skip_on_cran()
        expect_error(search_fulltext("red",page_size=10,sort_by="blurg"))
        ## sort by scientific name
        ## note that ALA sorting is case-sensitive, with A-Z preceding a-z
        temp <- search_fulltext("red",page_size=10,sort_by="scientificName")$data$scientificName
        temp <- temp[grepl("^[A-Z]",temp)]
        expect_equal(order(temp),1:length(temp))
        ## descending order
        temp <- search_fulltext("red",page_size=10,sort_by="scientificName",sort_dir="desc")$data$scientificName
        temp <- temp[grepl("^[A-Z]",temp)]
        expect_equal(order(temp),length(temp):1)
    })
}
check_caching(thischeck)

## not tested yet: S3method(print,search_fulltext)

thischeck=function() {
    test_that("search_layers generally works as expected", {
        skip_on_cran()
        expect_that(search_layers(type="all"),is_a('data.frame'))
        expect_that(search_layers(type="all",output_format="complete"),is_a('data.frame'))
        expect_that(nrow(search_layers(type="all")),is_more_than(50))
        expect_that(nrow(search_layers(type="all",query="bilbobaggins")),equals(0))
        expect_error(search_layers(type="bilbobaggins"))
        tmp <- search_layers(type = "shapes" ,query="World Heritage")
        expect_lt(nchar(tmp$shortName),nchar(tmp$name))
        skip("NBN only has one type of layer 'Contextual' - but currently no warning if 'grids' type used")
        expect_warning(search_layers(type="grids"))
    })
}
check_caching(thischeck)

## not tested yet: S3method(print,search_layers)

thischeck=function() {
    test_that("search_names can cope with factor inputs", {
        skip_on_cran()
        expect_equal(search_names(factor("Grevillea humilis")),search_names("Grevillea humilis"))
    })
}
check_caching(thischeck)

thischeck=function() {
    test_that("search_names can cope with all-unrecogized names", {
        skip_on_cran()
        expect_equal(nrow(search_names("fljkhdlsi")),1)
        expect_equal(nrow(search_names(c("fljkhdlsi","sdkhfowbiu"))),2)
        expect_true(all(is.na(search_names(c("fljkhdlsi","sdkhfowbiu"))$guid)))
    })
}
check_caching(thischeck)

thischeck=function() {
    test_that("unexpected case-related behaviour in search_names has not changed", {
        skip_on_cran()
        expect_equal(search_names("Leuctra geniculata")$name,"Leuctra geniculata")
        expect_equal(search_names("Leuctra Geniculata")$name,"Leuctra geniculata")
        expect_equal(search_names("Leuctra geniculat")$name,as.character(NA))
        expect_equal(search_names("Leuctra Geniculat")$name,as.character(NA))
    })
}
check_caching(thischeck)
    
thischeck=function() {
    test_that("nonbreaking spaces not present in names", {
        skip_on_cran()
        expect_false(any(colSums(apply(search_fulltext("Gallirallus australis")$data,2,function(z)grepl("\ua0",z)))>0))
        expect_false(grepl("\ua0",search_names("Gallirallus australis")$name))
    })
}
check_caching(thischeck)


thischeck=function() {
    test_that("search_names returns occurrence counts when asked", {
        skip_on_cran()
        expect_false(is.na(search_names("Leuctra",occurrence_count=TRUE)$occurrenceCount))
        expect_equal(is.na(search_names(c("Leuctra geniculata","isdulfsadh"),occurrence_count=TRUE)$occurrenceCount),c(FALSE,TRUE))
        expect_output(print(search_names(c("Leuctra geniculata","isdulfsadh"),occurrence_count=TRUE)),"occurrenceCount")
        expect_null(search_names(c("Leuctra geniculata","isdulfsadh"),occurrence_count=FALSE)$occurrenceCount)
        expect_equal(length(grep("occurrenceCount",capture.output(print(search_names(c("Leuctra geniculata","isdulfsadh"),occurrence_count=FALSE))))),0) ## "occurrenceCount" should not appear in the print(...) output

        expect_false(is.list(search_names(c("blahblah"),occurrence_count=TRUE)$occurrenceCount))
        expect_false(is.list(search_names(c("blahblah","jdfhsdjk"),occurrence_count=TRUE)$occurrenceCount))
        expect_false(is.list(search_names(c("Leuctra geniculata","blahblah","jdfhsdjk"),occurrence_count=TRUE)$occurrenceCount))
        expect_false(is.list(search_names(c("Leuctra geniculata","Grevillea"),occurrence_count=TRUE)$occurrenceCount))
        expect_false(is.list(search_names(c("Leutra"),occurrence_count=TRUE)$occurrenceCount))

        
    })
}
check_caching(thischeck)

thischeck = function() {
  test_that("search arguments in NBN4R package match arguments in ALA4R package", {
    expect_named(formals(search_names),names(formals(ALA4R::search_names)),ignore.order = TRUE)
    expect_named(formals(search_fulltext),names(formals(ALA4R::search_fulltext)),ignore.order = TRUE)
    expect_named(formals(search_layers),names(formals(ALA4R::search_layers)),ignore.order = TRUE)
  })
}
check_caching(thischeck)

## not tested yet: S3method(print,search_names)
          

## not tested yet: export(search_partial_name)
## not tested yet: S3method(print,search_partial_name)
