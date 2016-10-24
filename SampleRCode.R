# J Scott 
# Estimating the effect of a new curriculum on mindset

#install.packages("RForcecom") # using a package to query the database
library(RForcecom)

# log into database to query records
username <- "" # username omitted from sample code
password <- "" # password omitted from sample code
instanceURL <- "https://www.salesforce.com/"
apiVersion <- "34.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)

# Execute SOQL (like SQL) to pull records

# Survey data stored in Contact object
mindsetQuery <- "SELECT Id, Site__c, Mindset_14_15_S1__c, Mindset_14_15_S2__c,  Full_Name__c FROM Contact WHERE Mindset_14_15_S1__c != Null AND Mindset_14_15_S2__c != Null "
mindset=rforcecom.query(session, mindsetQuery)

# Attendance data stored in Contact Object
attendQuery = "SELECT Id, Site__c, TT_Sessions_Attended_9th_Grade_S1__c, TT_Sessions_Attended_9th_Grade_S2__c, TT_Sessions_Signed_up_9th_Grade_S1__c, TT_Sessions_Signed_up_9th_Grade_S2__c FROM Contact WHERE (Site__c = 'East Palo Alto' OR Site__c = 'Oakland') AND High_School_Graduating_Class__c = '2018' AND Admitted__c = 'Admitted and Accepted'"
attendance = rforcecom.query(session, attendQuery)

# Academic data stored in Student Activity Object
gpaQuery = "SELECT Contact__r.Id, Contact__r.Site__c, X9_1__c, X9_2__c FROM Student_Activity__c WHERE Contact__r.High_School_Graduating_Class__c = '2018' AND Contact__r.Admitted__c = 'Admitted and Accepted' AND (Contact__r.Site__c = 'East Palo Alto' OR Contact__r.Site__c='Oakland') AND RecordType.Id = '01250000000Hb3y'"
gpa = rforcecom.query(session, gpaQuery)

# Rename variable to Id to facilitate matching/merging tables
colnames(gpa)[1]= "Id"

# Clean Data

# Keeps relevant data as numeric values
mindset$y1=as.numeric(as.character(mindset$Mindset_14_15_S1__c))
mindset$y2=as.numeric(as.character(mindset$Mindset_14_15_S2__c))
mindset_epa = mindset[mindset$Site__c=="East Palo Alto",]

# creates longitudinal dataset
longitudinal=reshape(mindset, idvar= "Id", varying=list(c("Mindset_14_15_S1__c","Mindset_14_15_S2__c")), v.names= "mindset", direction="long")

# recodes treatment indicator, stores as numeric, then creates interaction term for regression model
longitudinal$site=ifelse(longitudinal$Site__c=="East Palo Alto",1,0)
longitudinal$y = as.numeric(as.character(longitudinal$mindset))
longitudinal$x = ifelse(longitudinal$time==1,0,1)
longitudinal$xsite= longitudinal$x*longitudinal$site

# merges Survey, Attendance, and Academic files using Id values
foo= merge(mindset_epa, attendance, by="Id")
gpa_mindset= merge(gpa, mindset_epa, by="Id")

# creates a missing data indicator for GPA
missing_gpa= gpa_mindset[is.na(gpa_mindset$X9_2__c),]

# Data Analysis
attach(longitudinal) # focuses analyses on final, cleaned dataset/matrix
longitudinal_epa= longitudinal[longitudinal$site==1,]

# a paired t-test for statistical significance comparing treatment and comparison groups
t.test(mindset_epa$y2,mindset_epa$y1, paired=TRUE, data=mindset_epa) // Mindset Scores among EPA students increased significantly, estimated at 3points

# a linear regression model, similar to t-test
results1 = lm (longitudinal$y ~ longitudinal$x , data = longitudinal_epa)
summary(results1) // Same substantive results as t-test

# a basic difference in difference model that estimate change in treatment group against change in comparison group
results2 = lm (longitudinal$y ~ longitudinal$x + site + xsite, data = longitudinal) // D-i-D estimate is not statistically significant
summary(results2)
