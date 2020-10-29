library(xml2)


# the function below uses the exact function signature as form_schema()
# in that sense, you could replace any call to form_schema by form_schema_ext
# it gets in addition to the form_schema columns, the common label, and the multilanguage labels if available
# it gets also the choice list and labels, in multilanguage if existing

form_schema_ext <-  function (flatten = FALSE, odata = FALSE, parse = TRUE, pid = get_default_pid(), 
                              fid = get_default_fid(), url = get_default_url(), un = get_default_un(), 
                              pw = get_default_pw(), odkc_version = get_default_odkc_version(), 
                              retries = get_retries(), verbose = get_ru_verbose()) 
{
  
  # gets basic schema
  frm_schema <-form_schema  (flatten, odata , parseE, pid , 
                             fid, url, un, 
                             pw , odkc_version, 
                             retries, verbose)
  
  # gets xml representation
  frm_xml <-  as_xml_document(form_xml (parse, pid, fid, 
                                        url, un, pw , 
                                        retries)) 
  
  
  ### parse translations:
  all_translations <- xml_find_all(frm_xml, "//text")
  
  # initialize dataframe
  extension <- data.frame(path = character(0), label = character(0), 
                          stringsAsFactors = FALSE)
  
  
  ### PART 1: parse labels:
  raw_labels <- xml_find_all(frm_xml, "//label")
  
  # iterate thorugh labels
  for (i in 1:length(raw_labels)){
    
    
    ## reads label
    this_rawlabel <-raw_labels[i]
    
    ## path
    # gets ref from parent, without leading "/data"
    this_path <-  sub("/data", "",
                      xml_attr(xml_parent(this_rawlabel), "ref"), 
                      6)
    
    # ensure this is a valid path
    if (!is.na(this_path)) {
      
      
      # adds new empty row:
      extension[nrow(extension)+1, ]<-rep(NA, ncol(extension))
      
      # adds path
      extension[nrow(extension), 'path'] <- this_path
      
      # first checks if it is multi-language label
      multi_lang <- xml_has_attr(this_rawlabel, "ref")
      
      if (multi_lang) {
        # if multi-language, finds all translations related to this path:
        id <- paste0("/data", this_path, ":label")
        translations <- all_translations[xml_attr(all_translations, "id") == id]
        
        # iterate through translations
        for (j in 1:length(translations)) {
          
          this_translation <- translations[j]
          
          # first check this is a regular text labels. Questions in ODK can have video, image and audio "labels", 
          # which will be skipped. This is identified by the presence of the 'form' attribute:
          is_regular_label <- !xml_has_attr(xml_find_first(this_translation,"./value"), "form")
          
          if (is_regular_label) {
            # reads the parent node to identify language:
            translation_parent<- xml_parent(this_translation)
            this_lang <- gsub(" ", "_", tolower(xml_attr(translation_parent, "lang")))
            
            # decide if 'default' language or specific language
            if (this_lang == "default") {
              # if 'default' language, save under column 'label':
              extension[nrow(extension), 'label'] <- xml_text(xml_find_first(this_translation,"./value"))
            }
            else {
              # check if language already exists in the datafram
              if (!(paste0("label_",this_lang) %in% colnames(extension))){
                
                # if not, create new column
                extension <- cbind(extension, data.frame(new_lang = rep(NA, nrow(extension))))
                colnames(extension)[ncol(extension)] <- paste0("label_",this_lang)
              }
              
              # adds the first value content of the translation
              extension[nrow(extension), paste0("label_",this_lang)] <- xml_text(xml_find_first(this_translation,"./value"))
            }
            
          }
          
        }
        
      }
      else {
        # extract content
        extension[nrow(extension), 'label'] <- xml_text(this_rawlabel)
        
      }
      
      ### PART 1.1: parse choice labels
      ## checks existence of  choice list:
      choice_items<-xml_find_all(xml_parent(this_rawlabel), "./item")
      if (length(choice_items)>0) {
        
        # check if 'choices' column already exist
        if (!('choices' %in% colnames(extension))){
          
          # if not, create new column
          extension <- cbind(extension, data.frame(choices = rep(NA, nrow(extension))))
        }
        
        # initialize lists
        choice_values <- list()
        choice_labels <- list()
        
        # iterate through choice list:
        for (jj in 1:length(choice_items)) {
          
          ## reads choice item
          this_choiceitem <- choice_items[jj]
          
          #value
          this_choicevalue<-xml_text(xml_find_first(this_choiceitem "./value"))
          choice_values[jj]<-this_choicevalue
          
          # raw label
          this_rawchoicelabel <- xml_find_first(this_choiceitem, "./label")
          
          # first checks if it is multi-language choice label
          multi_lang_choice <- xml_has_attr(this_rawchoicelabel, "ref")
          
          if (multi_lang_choice) {
            id_choice <- paste0("/data", this_path,"/",this_choicevalue, ":label")
            choice_translations <- all_translations[xml_attr(all_translations, "id") == id_choice]
            
            
            # iterate through choice translations
            for (kk in 1:length(choice_translations)) {
              
              # read translation
              this_choicetranslation <- choice_translations[kk]
              
              # first check this is a regular text labels. Questions in ODK can have video, image and audio "labels", 
              # which will be skipped. This is identified by the presence of the 'form' attribute:
              is_regular_choicelabel <- !xml_has_attr(xml_find_first(this_choicetranslation,"./value"), "form")
              
              if (is_regular_choicelabel) {
                # reads the parent node to identify language:
                choice_translation_parent<- xml_parent(this_choicetranslation)
                this_choicelang <- gsub(" ", "_", tolower(xml_attr(choice_translation_parent, "lang")))
                
                # decide if 'default' language or specific language
                if (this_choicelang == "default") {
                  # if 'default' language, save under 'choice':
                  choice_labels[['base']][jj] <- xml_text(xml_find_first(this_choicetranslation,"./value"))
                }
                else {
                  # check if language already exists in the dataframe
                  if (!(paste0("choices_",this_choicelang) %in% colnames(extension))){
                    
                    # if not, create new column
                    extension <- cbind(extension, data.frame(new_choicelang = rep(NA, nrow(extension))))
                    colnames(extension)[ncol(extension)] <- paste0("choices_",this_choicelang)
                  }
                  
                  # adds the first value content of the translation
                  choice_labels[[paste0("choices_",this_choicelang)]][jj] <- xml_text(xml_find_first(this_choicetranslation,"./value"))
                }
                
              }
              
            }
          }
          else {
            
            choice_labels[['base']][jj]<- xml_text(this_rawchoicelabel)
          }
        }
        
        # add to the extended table:
        for (this_choicelang in names(choice_labels)) {
          these_choicelabels <- choice_labels[[this_choicelang]]
          
          if (this_choicelang == "base"){
            this_choicelang_colname <- "choices"
          }
          else {
            this_choicelang_colname <-this_choicelang
          }
          
          extension[nrow(extension), this_choicelang_colname] <- list(list(list(values = unlist(choice_values), 
                                                                                labels = unlist(these_choicelabels))))
        }
        
      }
      
    }
  }
  
  
  # join:
  fs_ext <- frm_schema %>% dplyr::left_join(extension, by = "path")
  
  ##
  return(fs_ext)
}
