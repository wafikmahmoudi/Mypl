Class Home.Controller Extends %CSP.REST
{
Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json+fhir";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
          <Route Url="/" Method="GET" Call="ListPatients" />
          <Route Url="/Observation/:id" Method="GET" Call="ListObservationsByPatient" />
          <Route Url="/:id" Method="GET" Call="GetPatientByID" />
          <Route Url="/api/Patient/" Method="GET" Call="GetPatientAPI" />
           <Route Url="/APIpatient/" Method="GET" Call="GetPatientOS" />
        </Routes>
}

ClassMethod ListPatients() As %Status
{
		Set tArr = []
        Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Patient where ID1=3")
        While rs.%Next() {
        set idd = $LISTTOSTRING((rs.%Get("identifier")),"")
        set pos = $FIND(rs.%Get("identifier"),"u")
        set pos = pos-4
        set idd = $EXTRACT(rs.%Get("identifier"),3,pos)
        
        set xx = $LISTTOSTRING((rs.%Get("identifier")),"")
        set pos1 = $FIND(xx,"oid")
        set pos1 = pos1+1
        set pos2 = $FIND(xx,"|")
        set uuid = $EXTRACT(xx,pos1,pos2-2)
        
        
        set title1 = rs.%Get("gender")
        if title1 = "male" 
        {set title = "Mr" }
        else
        {set title = "Mme"}
        
      
      //Patient 
        Set rs2 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Patient where identifier Like'%"_idd_"%'")
        While rs2.%Next() {
         set id2 = rs2.%Get("Key")
        }
       
       
       //Observation
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'height'")
        While rs3.%Next() {
         set height = rs3.%Get("codeValueQuantity")
        }
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'weight'")
        While rs3.%Next() {
         set weight = rs3.%Get("codeValueQuantity")
         
        }
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'imc'")
        While rs3.%Next() {
         set imc = rs3.%Get("codeValueQuantity")
        }
        
        
        //Allergy
         Set alg = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.AllergyIntolerance where patient = '"_id2_"'")
        While alg.%Next() {
         set datealg = alg.%Get("date")
         set contentalg = alg.%Get("category")
         set highlightalg = alg.%Get("verificationStatus")
        }
        
        
        //Question
        Set qst = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Questionnaire where subjectType Like '%"_id2_"%'")
        While qst.%Next() {
         set codeqst = qst.%Get("code")
        set codeqst = $LISTTOSTRING(codeqst,"")
        set pos = $FIND(codeqst,"|")
        set codeqst = $EXTRACT(codeqst,pos,*-0)
      if codeqst = "COMORBIDITY"
      {
      set dateqst= qst.%Get("date")
      set contentqst = qst.%Get("title")
      set highlightqst = qst.%Get("status")			
      
      }
       if codeqst '= "COMORBIDITY"
      {
      set contentqst2 = qst.%Get("description")
      set textqst2 = qst.%Get("title")
      set statusqst2 = qst.%Get("status")
      
      }
        }
        
        //Familymemberhistory
         Set fml = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.FamilyMemberHistory where patient = '"_id2_"'")
        While fml.%Next() {
         set datefml = fml.%Get("date")
         set highlightfml = fml.%Get("status")
        set contentfml = fml.%Get("relationship")
        set contentfml = $LISTTOSTRING(contentfml,"")
        set pos = $FIND(contentfml,"|")
        set contentfml = $EXTRACT(contentfml,pos,*-0)
        }
        
        //medical_proposal
        Set mdl = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.MedicationRequest where patient = '"_id2_"'")
        While mdl.%Next() {
        set contentmdl = mdl.%Get("code")
        set contentmdl = $LISTTOSTRING(contentmdl,"")
        set pos = $FIND(contentmdl,"|")
        set contentmdl = $EXTRACT(contentmdl,1,pos-2)
        set pos2 = $FIND(contentmdl," ")
        	set contentmdl = $EXTRACT(contentmdl,pos2,*-0)
        	set colormdl = mdl.%Get("intent")
        set textmdl = mdl.%Get("identifier")
        set textmdl = $LISTTOSTRING(textmdl,"")
        set pos = $FIND(textmdl,"|")
        	set textmdl = $EXTRACT(textmdl,pos,*-0)
         		}
         		
        //clinical data
         Set cln = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.ClinicalImpression where patient = '"_id2_"'")
        While cln.%Next() {
        set textcln = cln.%Get("findingCode")
         set textcln = $LISTTOSTRING(textcln,"")
        set pos = $FIND(textcln,"|")
        	set textcln = $EXTRACT(textcln,pos,*-0)
        	set colorcln = cln.%Get("status")
        
        
        }
 
          Do tArr.%Push({
          
            "uuid":         (uuid),
             "hospital_uuid" :  (uuid),
            "title":         (title),
            "name":       ($LISTTOSTRING((rs.%Get("given")),"")),
            "family":   ($LISTTOSTRING((rs.%Get("family")),"")),
            "zip_code":   ($LISTTOSTRING((rs.%Get("addressPostalcode")),"")),
            "city":   ($LISTTOSTRING((rs.%Get("addressState")),"")), 
            "age" : 25,
            "height":       (height),
            "weight":       (weight),
            "imc":       (imc),
             "breast_cup": "C",
             "ps": 33,
             "prop1": "Suggest over.",
             "prop2": "15",
             "prop3": "Body break.",
             "prop4": "Inside country.",
             "prop5": "Book southern.",
            "biology": [],
            "medical_history": 
              {
                  "personal_history": [],
                  "family_history": [
                   {
                   	"date": (datefml),
                   	"content": (contentfml),
                   	"highlight": "false"
        			}
                  
                  ],
                   "allergies_history":
                   [
                    {
        "date": (datealg),
          "content": ($LISTTOSTRING((contentalg),"")),
          "highlight":  ($LISTTOSTRING((highlightalg),""))
        }
                   
                   ] 
              },
         "comorbidities": [
        {
      "date": (dateqst),
      "content": (contentqst),
      "highlight": "false"
        }],
          "lifestyle": [],
          "scores": {
          
          },
       "history_of_disease": "",
         "model_2D": [],
       "question_asked": {
        	"content": (contentqst2),
       		"tags": [
       					{
       					"text": (textqst2),
       					"color": "BLUE"
        				}
        				]
        
        },
         "medical_proposal": [(contentmdl)],
         "treatments": [
         		{
         			 "text": (textmdl),
         			 "color": "BLUE"
         		}
    					],
    	"clinical_trials_options": [
    			{
    			"text": (textcln),
    			"color": "BLUE"
    	
    			}
    	
    	
    								],
    			"complexity": "SIMPLE"
              
          })
        }

        Write tArr.%ToJSON()
        Quit $$$OK
}




ClassMethod GetPatientByID(id As %String) As %Status
{
	
		 set array = [] 
		 set i =1
		 while (i<5)
		 {
		 set json ={}
		 set json.nom= "newNextDatePlan"
	     set json.prenom = "rset.patient"
	     do array.%Push(json)
	     set i = i+1
	     }
	     
	     
	    
		 set array2 = [] 
		 set i2 =1
		 while (i2<5)
		 {
		 set json ={}
		 set json.nom= "newNextDatePlan"
	     set json.prenom = "rset.patient"
	     do array2.%Push(json)
	     set i2 = i2+1
	     }
	     
	     set array1 = [(array),(array2)]
		w array1.%ToJSON()
		
        Quit $$$OK
		  
}


ClassMethod GetPatientAPI() As %Status
{
			Set tArr = []
			set trt = []

	
	try {
	
			s request=##class(%Net.HttpRequest).%New()
			set request.Https = 1
			do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
			do request.SetHeader("Content-Type","application/json")
			Do request.SetParam("_format","json")
			set request.SSLConfiguration = "MyplSSL"
			set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485")

			 if request.HttpResponse.StatusCode <= 400 {
			     set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    //quand on a [] il faut mettre getiterator et getnext
			     set identifier = jsonData.identifier
			     set iter = identifier.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set uuid=source.system
			     
			      }
			      //
			      set name = jsonData.name
			     set iter2 = name.%GetIterator()
			     while iter2.%GetNext(.key,.source2) 
			     {
			     set family = source2.family
			     set names=source2.given.%GetIterator()
			     while names.%GetNext(.key,.source3) 
			     {set name = source3}
			     
			     set titels=source2.prefix.%GetIterator()
			     while titels.%GetNext(.key,.source4) 
			     {set titel = source4 }
			      }
			      //
			      
			       set address = jsonData.address
			     set iter = address.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set lines = source.line.%GetIterator()
			     while lines.%GetNext(.key,.ads) 
			     {  set addresse = ads }
			     set city=source.city
			     set state = source.state
			     set postalCode = source.postalCode
			     } 
			     
		
			   }
			    else
			    {w " // notfound : "_request.HttpResponse.StatusCode}
			    
			//////////////////////Observation//////////////////////////////////////////////
			s request=##class(%Net.HttpRequest).%New()
			set request.Https = 1
			do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
			do request.SetHeader("Content-Type","application/json")
			Do request.SetParam("_format","json")
			set request.SSLConfiguration = "MyplSSL"
			set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/Observation")
			set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set code =resource.code.coding
			     set display2=code.%GetIterator()
			     while display2.%GetNext(.key,.source4) 
			     {
			     set display = source4.display
			
			     
			     if (display = "Body Weight")
			     {
			     set valueweight=resource.valueQuantity.value
			    
			     }
			      ELSEIF  (display = "height")
			     {
			     set valueheight=resource.valueQuantity.value
			    
			     }
			       ELSEIF  (display = "imc")
			     {
			     set valueimc=resource.valueQuantity.value
			   
			     }
			   
			     }
			   
			      }
			      
			      
/////////////////////////////////      FamilyMemberHistory    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/FamilyMemberHistory")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateFML =resource.date
			     set conditionFML = resource.condition
			     set display3=conditionFML.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set TextFML = source5.code.text}
			    }
			    
/////////////////////////////////      AllergyIntolerance    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/AllergyIntolerance")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateALG =resource.onsetDateTime
			     set noteALG = resource.note
			     set display3=noteALG.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set textALG = source5.text}
			     }
/////////////////////////////////      Historique medical du patient    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/Condition")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateHP =resource.onsetDateTime
			     set textHP = resource.code.text
			    }
		
/////////////////////////////////     Medication  du patient    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/MedicationRequest")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set contained= source.resource.contained
			     set containeds = contained.%GetIterator()
			     while containeds.%GetNext(.key,.cd) 
			     {
			      set code = cd.code.coding
			     set display4=code.%GetIterator()
			     while display4.%GetNext(.key,.source6) 
			     {
			     set json ={}
			     set urlMED = source6.system
			     set codeMED = source6.code
			     set json.text= codeMED
			     set json.color = "BLUE"
			     		do trt.%Push(json)
			   
			     }
			     }}
		
///////////////////////////////////////////////////      ClinicalImpression    ////////////////////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/ClinicalImpression")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set statusCI =resource.status
			    }
			    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			    		
		
			      
		 Do tArr.%Push({ 
			    
			 "uuid":         (uuid),
             "hospital_uuid" :  (uuid),
            "title":         (titel),
            "name":       (name),
            "family":   (family),
            "zip_code":   (postalCode),
            "city":   (state), 
            "age" : 25,
            "height":       (valueheight),
            "weight":       (valueweight),
            "imc":       (valueimc),
             "breast_cup": "C",
             "ps": 33,
             "prop1": "Suggest over.",
             "prop2": "15",
             "prop3": "Body break.",
             "prop4": "Inside country.",
             "prop5": "Book southern.",
                      "biology": [],
            "medical_history": 
              {
                  "personal_history": [
                      {
				        "date": (dateHP),
				        "content": (textHP),
				        "highlight": "true"
				      }
                  
                  ],
                  "family_history": [
                   {
                   	"date": (dateFML),
                   	"content": (TextFML),
                   	"highlight": "false"
        			}
                  
                  ],
                   "allergies_history":
                   [
                    {
                    "date": (dateALG),
          "content": (textALG),
          "highlight":  "false"
        }
                   
                   ] 
              },
          "comorbidities": [],
          "lifestyle": [],
          "scores": {},
          "history_of_disease": "",
          "model_2D": [],
          "question_asked": { },
          "medical_proposal": [(urlMED)],
            "treatments": (trt),
    	"clinical_trials_options": [
    			{
    			"text": (statusCI),
    			"color": "BLUE"
    			}
    			],
    			"complexity": "SIMPLE"
			    })	
			    
			     Write tArr.%ToJSON()    
			    
			    
			    
			    
			    
		}Catch ex {	Set tSC=ex.AsStatus()}
		Quit 1


}


ClassMethod GetPatientOS() As %Status
	{
			Set tArr = []
			set trt = []
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	try {
	
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				//w myPatient.%ToJSON() 
				set myPatient = myPatient.%ToJSON() 
		


			     //set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    set jsonData = {}.%FromJSON(myPatient)   
			    //quand on a [] il faut mettre getiterator et getnext
			     set identifier = jsonData.identifier
			     set iter = identifier.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set uuid=source.system
			     set ipp = source.value
			      }
			      //
			      
			      
			      
			     set name = jsonData.name
			     set iter2 = name.%GetIterator()
			     while iter2.%GetNext(.key,.source2) 
			     {
			     set family = source2.family
			     set names=source2.given.%GetIterator()
			     while names.%GetNext(.key,.source3) 
			     {set name = source3}
			     
			     set titels=source2.prefix.%GetIterator()
			     while titels.%GetNext(.key,.source4) 
			     {set titel = source4 }
			      }
			      //
			      set gender = jsonData.gender
			      set birthDate = jsonData.birthDate
			      
			     set address = jsonData.address
			     set iter = address.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set lines = source.line.%GetIterator()
			     while lines.%GetNext(.key,.ads) 
			     {  set addresse = ads }
			     set city=source.city
			     set state = source.state
			     set postalCode = source.postalCode
			     } 
			     
			     
			     set telecom = jsonData.telecom
			     set iter2 = telecom.%GetIterator()
			     while iter2.%GetNext(.key,.telecom1) 
			     {
			     set phone = telecom1.system
			     set number = telecom1.number
			     set typephone = telecom1.use
			      }
		
		
			     set communication = jsonData.communication
			     set iter2 = communication.%GetIterator()
			     while iter2.%GetNext(.key,.communication1) 
			     {
			     set lang1 = communication1.language.coding
			     w "hell "
			       set iterlang = lang1.%GetIterator()
			       while iterlang.%GetNext(.key,.lang2) 
			     { set langue = lang2.code}
			      }
			   
			 
			    
			//////////////////////                       Observation                //////////////////////////////////////////////
			
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/Observation"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     
			     set typeTumor = resource.meta.profile
			     set profile = typeTumor.%GetIterator()
			     while profile.%GetNext(.keyp,.sourcep) 
			     {
			     set TypeT = sourcep
			     
			     if TypeT = "http://hl7.org/fhir/us/mcode/StructureDefinition/mcode-tnm-clinical-stage-group"
			     {
			          //valueCodeableConcept racine//
			     set coding1 = resource.valueCodeableConcept.coding
			     set codes = coding1.%GetIterator()
			     while codes.%GetNext(.key,.source) 
			     {set valueCodeableConceptracine = source.code 
			     w "valueCodeableConceptracine : "_valueCodeableConceptracine
			     w "   /   "}
			     
			     
			     //methode racine///
			     set coding2 = resource.method.coding
			     set codes2 = coding2.%GetIterator()
			     while codes2.%GetNext(.key,.source2) 
			     {set methoderacine = source2.code 
			     w "methoderacine : "_methoderacine
			     w " // fin methode//   "}
			     
			     }
			     
			       if TypeT = "http://hl7.org/fhir/us/mcode/StructureDefinition/mcode-tnm-clinical-primary-tumor-category"
			     {
			     
			               				//   valueCodeableConcept primary   //
			     set coding1 = resource.valueCodeableConcept.coding
			     set codes = coding1.%GetIterator()
			     while codes.%GetNext(.key,.source) 
			     {set valueCodeableConceptprimary = source.code 
			     w "valueCodeableConceptprimary : "_valueCodeableConceptprimary
			     w "   /   "}
			     
			     
			     							//    methode primary    ///
			     set coding2 = resource.method.coding
			     set codes2 = coding2.%GetIterator()
			     while codes2.%GetNext(.key,.source2) 
			     {set methodeprimary = source2.code 
			     w "methodeprimary : "_methodeprimary
			     w " // fin methode//   "}
			     
			     
			     }
			     
			     
			
			  
			  
			  
			    //valueCodeableConcept racine//
			    
			    }
			
			   
			      }
			      
			      
			      
			   /////////////////////////////////                        DiagnosticReport                          //////////////////////////////////////////////		      
			      
			   	set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/DiagnosticReport"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set codediagno1 = resource.code.coding
			     set codes = codediagno1.%GetIterator()
			     while codes.%GetNext(.key,.source2) 
			     {set codediagno = source2.code 
			     w "codediagno : "_codediagno
			     w "   /   "}
			     
			     set resultat =  resource.result
			     set ref = resultat.%GetIterator()
			     while ref.%GetNext(.key,.source2) 
			     {
			      set reference = source2.reference 
			      
			      
			      
			      if reference '= "Observation/mCODEGenomicRegionStudiedExample01"
			      {
			      
			      //chercher mcode-cancer-genetic-variant
			      
			   	set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = reference
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				set jsonData = {}.%FromJSON(myPatient)   
			 
			     w " in "
			     set coding2= jsonData.valueCodeableConcept.coding
			     set iter = coding2.%GetIterator()
			      while iter.%GetNext(.key,.sourcegenetic) 
			     {
			     set valueCodeableConceptgenetic = sourcegenetic.code
			     w "dddd : "_valueCodeableConceptgenetic
			     w "   //    "
			     }
			     
			     }	
			     }}		      
			      
/////////////////////////////////      FamilyMemberHistory    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/FamilyMemberHistory"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateFML =resource.date
			     set conditionFML = resource.condition
			     set display3=conditionFML.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set TextFML = source5.code.text}
			    }
			    
/////////////////////////////////      AllergyIntolerance    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/AllergyIntolerance"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
				 set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateALG =resource.onsetDateTime
			     set noteALG = resource.note
			     set display3=noteALG.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set textALG = source5.text}
			     }
/////////////////////////////////                           Condition                    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/Condition"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateHP =resource.onsetDateTime
			     set textHP = resource.code.text
			     
			     //clinicalstatus//
			     set coding = resource.clinicalStatus.coding
			     set cods=coding.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set clinicalStatus = source.code}
			     
			     //verification status///
			     set coding2 = resource.verificationStatus.coding
			     set cods=coding2.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set verificationStatus = source.code}
			     
			     
			     
			     //code condition//
			     set coding2 = resource.code.coding
			     set cods=coding2.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set codecondition = source.code }
			     
			     set bodySite = resource.bodySite
			     set coding=bodySite.%GetIterator()
			     while coding.%GetNext(.key,.source) 
			     {set codebodySite = source.code }
			     set valueDateTime =resource.onsetDateTime
			     
			     //stage//
			     set stage = resource.stage
			     set summary=stage.%GetIterator()
			     while summary.%GetNext(.key,.source) 
			     {
			     set coding= source.summary.coding
			     set cd2=coding.%GetIterator()
			     while cd2.%GetNext(.key,.source2) 
			     {
			    
			     set codestage = source2.code
			     set textstage = source2.display
			
			     }
			     set ass1= source.assessment
			      set cd3=ass1.%GetIterator()
			     while cd3.%GetNext(.key,.source3) 
			     { set textassessment = source3.display }
			     
			     	}
			     //note//
			        set notes = resource.note
			     set texts=notes.%GetIterator()
			     while texts.%GetNext(.key,.source) 
			     { set notecondition = source.text }
			     
			     
			    //severity//
			      set coding3 = resource.severity.coding
			     set cods3=coding3.%GetIterator()
			     while cods3.%GetNext(.key,.source) 
			     {set severity = source.display }
			     
			    }
			    
			    
			    
			    
		
/////////////////////////////////     Medication  du patient    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/MedicationRequest"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set contained= source.resource.contained
			     set containeds = contained.%GetIterator()
			     while containeds.%GetNext(.key,.cd) 
			     {
			      set code = cd.code.coding
			     set display4=code.%GetIterator()
			     while display4.%GetNext(.key,.source6) 
			     {
			     set json ={}
			     set urlMED = source6.system
			     set codeMED = source6.code
			     set json.text= codeMED
			     set json.color = "BLUE"
			     		do trt.%Push(json)
			   
			     }
			     }}
		
///////////////////////////////////////////////////      ClinicalImpression    ////////////////////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/ClinicalImpression"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				
				set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set statusCI =resource.status
			    }
			    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			    		


			     Write tArr.%ToJSON()    
			    
			    
			    
			    
			    
		}Catch ex {	Set tSC=ex.AsStatus()}
		Quit 1
		
	
	}

















Class Home.Controller Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json+fhir";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
          <Route Url="/" Method="GET" Call="ListPatients" />
          <Route Url="/Observation/:id" Method="GET" Call="ListObservationsByPatient" />
          <Route Url="/:id" Method="GET" Call="GetPatientByID" />
          <Route Url="/api/Patient/" Method="GET" Call="GetPatientAPI" />
           <Route Url="/APIpatient/" Method="GET" Call="GetPatientOS" />
        </Routes>
}

ClassMethod ListPatients() As %Status
{
		Set tArr = []
        Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Patient where ID1=3")
        While rs.%Next() {
        set idd = $LISTTOSTRING((rs.%Get("identifier")),"")
        set pos = $FIND(rs.%Get("identifier"),"u")
        set pos = pos-4
        set idd = $EXTRACT(rs.%Get("identifier"),3,pos)
        
        set xx = $LISTTOSTRING((rs.%Get("identifier")),"")
        set pos1 = $FIND(xx,"oid")
        set pos1 = pos1+1
        set pos2 = $FIND(xx,"|")
        set uuid = $EXTRACT(xx,pos1,pos2-2)
        
        
        set title1 = rs.%Get("gender")
        if title1 = "male" 
        {set title = "Mr" }
        else
        {set title = "Mme"}
        
      
      //Patient 
        Set rs2 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Patient where identifier Like'%"_idd_"%'")
        While rs2.%Next() {
         set id2 = rs2.%Get("Key")
        }
       
       
       //Observation
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'height'")
        While rs3.%Next() {
         set height = rs3.%Get("codeValueQuantity")
        }
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'weight'")
        While rs3.%Next() {
         set weight = rs3.%Get("codeValueQuantity")
         
        }
        Set rs3 = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Observation where patient = '"_id2_"' and codeValueConcept = 'imc'")
        While rs3.%Next() {
         set imc = rs3.%Get("codeValueQuantity")
        }
        
        
        //Allergy
         Set alg = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.AllergyIntolerance where patient = '"_id2_"'")
        While alg.%Next() {
         set datealg = alg.%Get("date")
         set contentalg = alg.%Get("category")
         set highlightalg = alg.%Get("verificationStatus")
        }
        
        
        //Question
        Set qst = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.Questionnaire where subjectType Like '%"_id2_"%'")
        While qst.%Next() {
         set codeqst = qst.%Get("code")
        set codeqst = $LISTTOSTRING(codeqst,"")
        set pos = $FIND(codeqst,"|")
        set codeqst = $EXTRACT(codeqst,pos,*-0)
      if codeqst = "COMORBIDITY"
      {
      set dateqst= qst.%Get("date")
      set contentqst = qst.%Get("title")
      set highlightqst = qst.%Get("status")			
      
      }
       if codeqst '= "COMORBIDITY"
      {
      set contentqst2 = qst.%Get("description")
      set textqst2 = qst.%Get("title")
      set statusqst2 = qst.%Get("status")
      
      }
        }
        
        //Familymemberhistory
         Set fml = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.FamilyMemberHistory where patient = '"_id2_"'")
        While fml.%Next() {
         set datefml = fml.%Get("date")
         set highlightfml = fml.%Get("status")
        set contentfml = fml.%Get("relationship")
        set contentfml = $LISTTOSTRING(contentfml,"")
        set pos = $FIND(contentfml,"|")
        set contentfml = $EXTRACT(contentfml,pos,*-0)
        }
        
        //medical_proposal
        Set mdl = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.MedicationRequest where patient = '"_id2_"'")
        While mdl.%Next() {
        set contentmdl = mdl.%Get("code")
        set contentmdl = $LISTTOSTRING(contentmdl,"")
        set pos = $FIND(contentmdl,"|")
        set contentmdl = $EXTRACT(contentmdl,1,pos-2)
        set pos2 = $FIND(contentmdl," ")
        	set contentmdl = $EXTRACT(contentmdl,pos2,*-0)
        	set colormdl = mdl.%Get("intent")
        set textmdl = mdl.%Get("identifier")
        set textmdl = $LISTTOSTRING(textmdl,"")
        set pos = $FIND(textmdl,"|")
        	set textmdl = $EXTRACT(textmdl,pos,*-0)
         		}
         		
        //clinical data
         Set cln = ##class(%SQL.Statement).%ExecDirect(,"SELECT* FROM HSFHIR_I0001_S.ClinicalImpression where patient = '"_id2_"'")
        While cln.%Next() {
        set textcln = cln.%Get("findingCode")
         set textcln = $LISTTOSTRING(textcln,"")
        set pos = $FIND(textcln,"|")
        	set textcln = $EXTRACT(textcln,pos,*-0)
        	set colorcln = cln.%Get("status")
        
        
        }
 
          Do tArr.%Push({
          
            "uuid":         (uuid),
             "hospital_uuid" :  (uuid),
            "title":         (title),
            "name":       ($LISTTOSTRING((rs.%Get("given")),"")),
            "family":   ($LISTTOSTRING((rs.%Get("family")),"")),
            "zip_code":   ($LISTTOSTRING((rs.%Get("addressPostalcode")),"")),
            "city":   ($LISTTOSTRING((rs.%Get("addressState")),"")), 
            "age" : 25,
            "height":       (height),
            "weight":       (weight),
            "imc":       (imc),
             "breast_cup": "C",
             "ps": 33,
             "prop1": "Suggest over.",
             "prop2": "15",
             "prop3": "Body break.",
             "prop4": "Inside country.",
             "prop5": "Book southern.",
            "biology": [],
            "medical_history": 
              {
                  "personal_history": [],
                  "family_history": [
                   {
                   	"date": (datefml),
                   	"content": (contentfml),
                   	"highlight": "false"
        			}
                  
                  ],
                   "allergies_history":
                   [
                    {
        "date": (datealg),
          "content": ($LISTTOSTRING((contentalg),"")),
          "highlight":  ($LISTTOSTRING((highlightalg),""))
        }
                   
                   ] 
              },
         "comorbidities": [
        {
      "date": (dateqst),
      "content": (contentqst),
      "highlight": "false"
        }],
          "lifestyle": [],
          "scores": {
          
          },
       "history_of_disease": "",
         "model_2D": [],
       "question_asked": {
        	"content": (contentqst2),
       		"tags": [
       					{
       					"text": (textqst2),
       					"color": "BLUE"
        				}
        				]
        
        },
         "medical_proposal": [(contentmdl)],
         "treatments": [
         		{
         			 "text": (textmdl),
         			 "color": "BLUE"
         		}
    					],
    	"clinical_trials_options": [
    			{
    			"text": (textcln),
    			"color": "BLUE"
    	
    			}
    	
    	
    								],
    			"complexity": "SIMPLE"
              
          })
        }

        Write tArr.%ToJSON()
        Quit $$$OK
}

ClassMethod GetPatientByID(id As %String) As %Status
{
	
		 set array = [] 
		 set i =1
		 while (i<5)
		 {
		 set json ={}
		 set json.nom= "newNextDatePlan"
	     set json.prenom = "rset.patient"
	     do array.%Push(json)
	     set i = i+1
	     }
	     
	     
	    
		 set array2 = [] 
		 set i2 =1
		 while (i2<5)
		 {
		 set json ={}
		 set json.nom= "newNextDatePlan"
	     set json.prenom = "rset.patient"
	     do array2.%Push(json)
	     set i2 = i2+1
	     }
	     
	     set array1 = [(array),(array2)]
		w array1.%ToJSON()
		
        Quit $$$OK
}

ClassMethod GetPatientAPI() As %Status
{
			Set tArr = []
			set trt = []

	
	try {
	
			s request=##class(%Net.HttpRequest).%New()
			set request.Https = 1
			do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
			do request.SetHeader("Content-Type","application/json")
			Do request.SetParam("_format","json")
			set request.SSLConfiguration = "MyplSSL"
			set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485")

			 if request.HttpResponse.StatusCode <= 400 {
			     set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    //quand on a [] il faut mettre getiterator et getnext
			     set identifier = jsonData.identifier
			     set iter = identifier.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set uuid=source.system
			     
			      }
			      //
			      set name = jsonData.name
			     set iter2 = name.%GetIterator()
			     while iter2.%GetNext(.key,.source2) 
			     {
			     set family = source2.family
			     set names=source2.given.%GetIterator()
			     while names.%GetNext(.key,.source3) 
			     {set name = source3}
			     
			     set titels=source2.prefix.%GetIterator()
			     while titels.%GetNext(.key,.source4) 
			     {set titel = source4 }
			      }
			      //
			      
			       set address = jsonData.address
			     set iter = address.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set lines = source.line.%GetIterator()
			     while lines.%GetNext(.key,.ads) 
			     {  set addresse = ads }
			     set city=source.city
			     set state = source.state
			     set postalCode = source.postalCode
			     } 
			     
		
			   }
			    else
			    {w " // notfound : "_request.HttpResponse.StatusCode}
			    
			//////////////////////Observation//////////////////////////////////////////////
			s request=##class(%Net.HttpRequest).%New()
			set request.Https = 1
			do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
			do request.SetHeader("Content-Type","application/json")
			Do request.SetParam("_format","json")
			set request.SSLConfiguration = "MyplSSL"
			set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/Observation")
			set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set code =resource.code.coding
			     set display2=code.%GetIterator()
			     while display2.%GetNext(.key,.source4) 
			     {
			     set display = source4.display
			
			     
			     if (display = "Body Weight")
			     {
			     set valueweight=resource.valueQuantity.value
			    
			     }
			      ELSEIF  (display = "height")
			     {
			     set valueheight=resource.valueQuantity.value
			    
			     }
			       ELSEIF  (display = "imc")
			     {
			     set valueimc=resource.valueQuantity.value
			   
			     }
			   
			     }
			   
			      }
			      
			      
/////////////////////////////////      FamilyMemberHistory    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/FamilyMemberHistory")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateFML =resource.date
			     set conditionFML = resource.condition
			     set display3=conditionFML.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set TextFML = source5.code.text}
			    }
			    
/////////////////////////////////      AllergyIntolerance    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/AllergyIntolerance")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateALG =resource.onsetDateTime
			     set noteALG = resource.note
			     set display3=noteALG.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set textALG = source5.text}
			     }
/////////////////////////////////      Historique medical du patient    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/Condition")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateHP =resource.onsetDateTime
			     set textHP = resource.code.text
			    }
		
/////////////////////////////////     Medication  du patient    //////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/MedicationRequest")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set contained= source.resource.contained
			     set containeds = contained.%GetIterator()
			     while containeds.%GetNext(.key,.cd) 
			     {
			      set code = cd.code.coding
			     set display4=code.%GetIterator()
			     while display4.%GetNext(.key,.source6) 
			     {
			     set json ={}
			     set urlMED = source6.system
			     set codeMED = source6.code
			     set json.text= codeMED
			     set json.color = "BLUE"
			     		do trt.%Push(json)
			   
			     }
			     }}
		
///////////////////////////////////////////////////      ClinicalImpression    ////////////////////////////////////////////////////////////
				s request=##class(%Net.HttpRequest).%New()
				set request.Https = 1
				do request.SetHeader("Authorization","Basic X1NZU1RFTTprU3NNMXMkX3BQTCMw")
				do request.SetHeader("Content-Type","application/json")
				Do request.SetParam("_format","json")
				set request.SSLConfiguration = "MyplSSL"
				set res =  request.Get("https://is.mypl.name:52773/csp/healthshare/demo/fhir/r4/Patient/4485/ClinicalImpression")
				set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set statusCI =resource.status
			    }
			    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			    		
		
			      
		 Do tArr.%Push({ 
			    
			 "uuid":         (uuid),
             "hospital_uuid" :  (uuid),
            "title":         (titel),
            "name":       (name),
            "family":   (family),
            "zip_code":   (postalCode),
            "city":   (state), 
            "age" : 25,
            "height":       (valueheight),
            "weight":       (valueweight),
            "imc":       (valueimc),
             "breast_cup": "C",
             "ps": 33,
             "prop1": "Suggest over.",
             "prop2": "15",
             "prop3": "Body break.",
             "prop4": "Inside country.",
             "prop5": "Book southern.",
                      "biology": [],
            "medical_history": 
              {
                  "personal_history": [
                      {
				        "date": (dateHP),
				        "content": (textHP),
				        "highlight": "true"
				      }
                  
                  ],
                  "family_history": [
                   {
                   	"date": (dateFML),
                   	"content": (TextFML),
                   	"highlight": "false"
        			}
                  
                  ],
                   "allergies_history":
                   [
                    {
                    "date": (dateALG),
          "content": (textALG),
          "highlight":  "false"
        }
                   
                   ] 
              },
          "comorbidities": [],
          "lifestyle": [],
          "scores": {},
          "history_of_disease": "",
          "model_2D": [],
          "question_asked": { },
          "medical_proposal": [(urlMED)],
            "treatments": (trt),
    	"clinical_trials_options": [
    			{
    			"text": (statusCI),
    			"color": "BLUE"
    			}
    			],
    			"complexity": "SIMPLE"
			    })	
			    
			     Write tArr.%ToJSON()    
			    
			    
			    
			    
			    
		}Catch ex {	Set tSC=ex.AsStatus()}
		Quit 1
}

ClassMethod GetPatientOS() As %Status
{
			Set tArr = []
			set trt = []
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	try {
	
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				//w myPatient.%ToJSON() 
				set myPatient = myPatient.%ToJSON() 
		


			     //set jsonData = {}.%FromJSON(request.HttpResponse.Data)   
			    set jsonData = {}.%FromJSON(myPatient)   
			    //quand on a [] il faut mettre getiterator et getnext
			     set identifier = jsonData.identifier
			     set iter = identifier.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set uuid=source.system
			     set ipp = source.value
			      }
			      //
			      
			      
			      
			     set name = jsonData.name
			     set iter2 = name.%GetIterator()
			     while iter2.%GetNext(.key,.source2) 
			     {
			     set family = source2.family
			     set names=source2.given.%GetIterator()
			     while names.%GetNext(.key,.source3) 
			     {set name = source3}
			     
			     set titels=source2.prefix.%GetIterator()
			     while titels.%GetNext(.key,.source4) 
			     {set titel = source4 }
			      }
			      //
			      set gender = jsonData.gender
			      set birthDate = jsonData.birthDate
			      
			     set address = jsonData.address
			     set iter = address.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set lines = source.line.%GetIterator()
			     while lines.%GetNext(.key,.ads) 
			     {  set addresse = ads }
			     set city=source.city
			     set state = source.state
			     set postalCode = source.postalCode
			     } 
			     
			     
			     set telecom = jsonData.telecom
			     set iter2 = telecom.%GetIterator()
			     while iter2.%GetNext(.key,.telecom1) 
			     {
			     set phone = telecom1.system
			     set number = telecom1.number
			     set typephone = telecom1.use
			      }
		
		
			     set communication = jsonData.communication
			     set iter2 = communication.%GetIterator()
			     while iter2.%GetNext(.key,.communication1) 
			     {
			     set lang1 = communication1.language.coding
			     w "hell "
			       set iterlang = lang1.%GetIterator()
			       while iterlang.%GetNext(.key,.lang2) 
			     { set langue = lang2.code}
			      }
			   
			 
			    
			//////////////////////                       Observation                //////////////////////////////////////////////
			
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/Observation"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			     while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     
			     set typeTumor = resource.meta.profile
			     set profile = typeTumor.%GetIterator()
			     while profile.%GetNext(.keyp,.sourcep) 
			     {
			     set TypeT = sourcep
			     
			     if TypeT = "http://hl7.org/fhir/us/mcode/StructureDefinition/mcode-tnm-clinical-stage-group"
			     {
			          //valueCodeableConcept racine//
			     set coding1 = resource.valueCodeableConcept.coding
			     set codes = coding1.%GetIterator()
			     while codes.%GetNext(.key,.source) 
			     {set valueCodeableConceptracine = source.code 
			     w "valueCodeableConceptracine : "_valueCodeableConceptracine
			     w "   /   "}
			     
			     
			     //methode racine///
			     set coding2 = resource.method.coding
			     set codes2 = coding2.%GetIterator()
			     while codes2.%GetNext(.key,.source2) 
			     {set methoderacine = source2.code 
			     w "methoderacine : "_methoderacine
			     w " // fin methode//   "}
			     
			     }
			     
			       if TypeT = "http://hl7.org/fhir/us/mcode/StructureDefinition/mcode-tnm-clinical-primary-tumor-category"
			     {
			     
			               				//   valueCodeableConcept primary   //
			     set coding1 = resource.valueCodeableConcept.coding
			     set codes = coding1.%GetIterator()
			     while codes.%GetNext(.key,.source) 
			     {set valueCodeableConceptprimary = source.code 
			     w "valueCodeableConceptprimary : "_valueCodeableConceptprimary
			     w "   /   "}
			     
			     
			     							//    methode primary    ///
			     set coding2 = resource.method.coding
			     set codes2 = coding2.%GetIterator()
			     while codes2.%GetNext(.key,.source2) 
			     {set methodeprimary = source2.code 
			     w "methodeprimary : "_methodeprimary
			     w " // fin methode//   "}
			     
			     
			     }
			     
			     
			
			  
			  
			  
			    //valueCodeableConcept racine//
			    
			    }
			
			   
			      }
			      
			      
			      
			   /////////////////////////////////                        DiagnosticReport                          //////////////////////////////////////////////		      
			      
			   	set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/DiagnosticReport"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set codediagno1 = resource.code.coding
			     set codes = codediagno1.%GetIterator()
			     while codes.%GetNext(.key,.source2) 
			     {set codediagno = source2.code 
			     w "codediagno : "_codediagno
			     w "   /   "}
			     
			     set resultat =  resource.result
			     set ref = resultat.%GetIterator()
			     while ref.%GetNext(.key,.source2) 
			     {
			      set reference = source2.reference 
			      
			      
			      
			      if reference '= "Observation/mCODEGenomicRegionStudiedExample01"
			      {
			      
			      //chercher mcode-cancer-genetic-variant
			      
			   	set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = reference
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				set jsonData = {}.%FromJSON(myPatient)   
			 
			     w " in "
			     set coding2= jsonData.valueCodeableConcept.coding
			     set iter = coding2.%GetIterator()
			      while iter.%GetNext(.key,.sourcegenetic) 
			     {
			     set valueCodeableConceptgenetic = sourcegenetic.code
			     w "dddd : "_valueCodeableConceptgenetic
			     w "   //    "
			     }
			     
			     }	
			     }}		      
			      
/////////////////////////////////      FamilyMemberHistory    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/FamilyMemberHistory"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateFML =resource.date
			     set conditionFML = resource.condition
			     set display3=conditionFML.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set TextFML = source5.code.text}
			    }
			    
/////////////////////////////////      AllergyIntolerance    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/AllergyIntolerance"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient) 
				 set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateALG =resource.onsetDateTime
			     set noteALG = resource.note
			     set display3=noteALG.%GetIterator()
			     while display3.%GetNext(.key,.source5) 
			     {set textALG = source5.text}
			     }
/////////////////////////////////                           Condition                    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/Condition"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
			
			
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set dateHP =resource.onsetDateTime
			     set textHP = resource.code.text
			     
			     //clinicalstatus//
			     set coding = resource.clinicalStatus.coding
			     set cods=coding.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set clinicalStatus = source.code}
			     
			     //verification status///
			     set coding2 = resource.verificationStatus.coding
			     set cods=coding2.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set verificationStatus = source.code}
			     
			     
			     
			     //code condition//
			     set coding2 = resource.code.coding
			     set cods=coding2.%GetIterator()
			     while cods.%GetNext(.key,.source) 
			     {set codecondition = source.code }
			     
			     set bodySite = resource.bodySite
			     set coding=bodySite.%GetIterator()
			     while coding.%GetNext(.key,.source) 
			     {set codebodySite = source.code }
			     set valueDateTime =resource.onsetDateTime
			     
			     //stage//
			     set stage = resource.stage
			     set summary=stage.%GetIterator()
			     while summary.%GetNext(.key,.source) 
			     {
			     set coding= source.summary.coding
			     set cd2=coding.%GetIterator()
			     while cd2.%GetNext(.key,.source2) 
			     {
			    
			     set codestage = source2.code
			     set textstage = source2.display
			
			     }
			     set ass1= source.assessment
			      set cd3=ass1.%GetIterator()
			     while cd3.%GetNext(.key,.source3) 
			     { set textassessment = source3.display }
			     
			     	}
			     //note//
			        set notes = resource.note
			     set texts=notes.%GetIterator()
			     while texts.%GetNext(.key,.source) 
			     { set notecondition = source.text }
			     
			     
			    //severity//
			      set coding3 = resource.severity.coding
			     set cods3=coding3.%GetIterator()
			     while cods3.%GetNext(.key,.source) 
			     {set severity = source.display }
			     
			    }
			    
			    
			    
			    
		
/////////////////////////////////     Medication  du patient    //////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/MedicationRequest"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				
				 set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set contained= source.resource.contained
			     set containeds = contained.%GetIterator()
			     while containeds.%GetNext(.key,.cd) 
			     {
			      set code = cd.code.coding
			     set display4=code.%GetIterator()
			     while display4.%GetNext(.key,.source6) 
			     {
			     set json ={}
			     set urlMED = source6.system
			     set codeMED = source6.code
			     set json.text= codeMED
			     set json.color = "BLUE"
			     		do trt.%Push(json)
			   
			     }
			     }}
		
///////////////////////////////////////////////////      ClinicalImpression    ////////////////////////////////////////////////////////////
				set url = "/csp/healthshare/demo/fhir/r4"
				set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
				set request = ##class(HS.FHIRServer.API.Data.Request).%New()
				set request.RequestPath = "Patient/4485/ClinicalImpression"
				set request.RequestMethod = "GET"
				do fhirService.DispatchRequest(request, .response)
				set myPatient = response.Json
				set myPatient = myPatient.%ToJSON() 
				
				set jsonData = {}.%FromJSON(myPatient)   
			     set entry = jsonData.entry
			     set iter = entry.%GetIterator()
			      while iter.%GetNext(.key,.source) 
			     {
			     set resource= source.resource
			     set statusCI =resource.status
			    }
			    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			    		


			     Write tArr.%ToJSON()    
			    
			    
			    
			    
			    
		}Catch ex {	Set tSC=ex.AsStatus()}
		Quit 1
}

}

}