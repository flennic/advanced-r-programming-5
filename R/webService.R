# Basic Data
base = "http://api.kolada.se/"
api_version = "v2/"

#' Fetch Municipalities
#'
#' @return Returns a data.frame containing all municipalities.
#' @export
#'
#' @examples fetchMunicipalities()
fetchMunicipalities = function() {
  endpoint = "municipality"
  webCall = paste(base, api_version, endpoint, sep="")
  
  # Execution
  response = GET(webCall)
  
  # Check Server Response
  if (response["status_code"] < 200 | response["status_code"] > 299) stop("HTTP Stauts code it not OK (not in range 200-299).")
  
  # Deserialization
  result = fromJSON(content(response, "text", encoding = "utf-8"), flatten = TRUE)
  
  return(as.data.frame(result))
}

#' Fetch KPIs
#'
#' @return Returns a data.frame containing all KPIs with their id and description.
#' @export
#'
#' @examples fetchKpis()
fetchKpis = function() {
  endpoint = "kpi_groups"
  webCall = paste(base, api_version, endpoint, sep="")
  
  # Execution
  response = GET(webCall)
  
  # Deserialization
  result = fromJSON(content(response, "text", encoding = "utf-8"), flatten = FALSE)
  
  # Check Server Response
  if (response["status_code"] < 200 | response["status_code"] > 299) stop("HTTP Stauts code it not OK (not in range 200-299).")
  
  # Prepare Data Frames
  kpi.group.data.frame = as.data.frame(result)
  kpi.data.frame = data.frame(member_id = integer(), member_title = character())
  
  # Extract required data
  for (i in 1:nrow(kpi.group.data.frame)) {
    group_kpi = kpi.group.data.frame[i, 3][[1]]
    kpi.data.frame = rbind(kpi.data.frame, group_kpi)
  }
  return(kpi.data.frame)
}

#' Fetch By Municipality
#'
#' @param municipality Id of the municipality.
#' @param year The year as integer.
#'
#' @return Returns a data.frame containing all KPIs belonging to the municipality in the given year.
#' @export
#'
#' @examples fetchByMunicipality(1440, 2012)
fetchByMunicipality = function(municipality, year){
  #http://api.kolada.se/v2/data/municipality/1860/year/2009
  
  endpoint = "data/municipality/"
  
  webCall = paste(base, api_version, endpoint, municipality, "/year/", year, sep="")
  
  # Execution
  response = GET(webCall)
  
  # Check Server Response
  if (response["status_code"] < 200 | response["status_code"] > 299) stop("HTTP Stauts code it not OK (not in range 200-299).")
  
  # Deserialization
  result = fromJSON(content(response, "text"), flatten = TRUE)
  return(as.data.frame(result))
}

#' Fetch By KPI
#'
#' @param kpi Id of the KPIs as a list. Seperator is a ','.
#' @param municipality Id of the municipality.
#' @param year (optional) The year as integer.
#'
#' @return Returns a data.frame containing the
#' @export
#'
#' @examples fetchByKpi(list("N00914,U00405"), 1440, 2012)
fetchByKpi = function(kpi, municipality , year = 0) {

  endpoint = "data/kpi/"

  webCall = paste(base, api_version, endpoint, sep="")
  
  for (i in 1:length(kpi)) {
    webCall = paste(webCall, kpi[i], sep="")
    if (i != length(kpi)) webCall = paste(webCall, ",", sep="")
  }
  
  webCall = paste (webCall, "/municipality/", municipality, sep="")

  if (year > 0) webCall = paste(webCall, "/year/", year, sep="")
  
  # Execution
  response = GET(webCall)

  # Check Server Response
  if (response["status_code"] < 200 | response["status_code"] > 299) stop("HTTP Stauts code it not OK (not in range 200-299).")
  
  # Deserialization
  result = fromJSON(content(response, "text"), flatten = TRUE)
  return(as.data.frame(result))
}

#a = fetchMunicipalities()
#b = fetchKpis()
#c = fetchByKpi(list("N00914,U00405"), 1440, 2012)
#d = fetchByMunicipality(1440, 2012)