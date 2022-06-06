# Maggies NSS Capstone

Capstone Project for Nashville Software School: Data Analytics Cohort 6
Exploratory analysis of correlation between criminal activity in Davidson County, TN as reported by Metro Nashville Police, and Covid-19 cases in Davidson County


## Description

Using PostgreSQL to explore datasets provided by Metro Nashville's open data portal, to examine what, if any, correlation exists between criminal activity, as defined by incidents responded to and recorded by Metro Nashville Police from 2015 - 2022, and Covid-19 trends. This analysis is specifically limited to Davidson County, TN. 
## Data Questions
- How has criminal activity risen or fallen in Davidson County as  whole, between 2015 - 2022? Are there certain types of crime that have increased or decreased during this period? 

*Data preceding the onset of the Covid-19 pandemic (2015 - 2019) will be examined to establish a baseline and more assuredly correlate trends in criminal activity to the Covid-19 pandemic.*

- Did criminal activity increase, decrease, or remain the same, during the Covid-19 pandemic? 
*Trends in Covid-19 cases will be established using daily confirmed cases from March 2020 - May 2022, as provided by Metro Nashville. This data will be overlayed with criminal incidents to examine correlation.*

## Known Issues and Challenges
-Reporting of criminal incidents by Metro Nashville PD is often inconsistent in data collection. Many incidents do not have complete data, and there is inconsistency is fields like incident description, weapon description, victim gender, etc. 

*Using a data dictionary provided by Metro Nashville PD, I was able to create consistency in standardized fields in incidents where data existed, but did not follow a standard format. Blank fields were filled with "Unknown" values where appropriate*

- Incident Numbers are not unique values - this would make it impossible to trend criminal activity as Incident Number is the primary identifier of an individual instance. 

*Incident numbers are generally 7 digits in length. To create unique identifiers, I numbered the first incident at 1,000,000 and added increments of +1 until the final incident. Because the total incident count is less than 1,000,000, I was able to remain within the 7-digit constraint while creating unique identifiers.*

- Metro Nashville incident data has several incidents which occurred outside of Davidson County - this project focuses exclusively on Davidson County, which necessitated removing these incidents. 

*87% of incident records do not contain a zip code, or location indicator easily used in geocoding. However, the majority of incidents do include a mapping point (Lat/Long). To identify incidents occurring in/outside of Davidson County, I downloaded a shapefile which was then loaded into Power BI. After transforming the mapping point to separate Latitude and Longitude indicators, I overlayed individual points on a Tennesee map with county boundaries. I noted the incident numbers of those occurring outside Davidson County, and removed these from the dataset.*
 
