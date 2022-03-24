
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.RobotLogListener
Library           RPA.FileSystem
Library           RPA.Archive

*** Variables ***
${problema}=    css:.alert
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download csv
    Open the robot order website
    Close modal
    Fill the form using the data from the csv file
    Zip the pdf Directory
    [Teardown]    Close the browser

*** Keywords ***
Download csv
    Download    https://robotsparebinindustries.com/orders.csv  overwrite=True
Open the robot order website
     Open Available Browser    https://robotsparebinindustries.com/#/robot-order

 Close modal
     Click Button  OK
Fill the form using the data from the csv file
    ${table}=    Read table from CSV    orders.csv
    Create Directory     ${CURDIR}${/}PDF    overwrite=True
    FOR    ${table}    IN    @{table}
        Fill the form with csv data and export pdf    ${table}
    END

Click Element If It Appears
    [Arguments]    ${locator}
    Mute Run On Failure    Click Button    order
    Run Keyword And Ignore Error    Click Button    order
Fill the form with csv data and export pdf 
    [Arguments]    ${table}
    Select From List By Value    head    ${table}[Head]
    Select Radio Button   body   id-body-${table}[Body] 
    Input Text    css:.form-control   ${table}[Legs]
    Input Text    address   ${table}[Address]
    Click Button    preview
    Wait Until Keyword Succeeds    1 min    1 sec    Expected Error
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}receipt.pdf
    ...    ${OUTPUT_DIR}${/}robot.png:align=center
    Add Files To PDF    ${files}    ${CURDIR}${/}PDF/receipt${table}[Order number].pdf
    Click Button  OK
Expected Error
    Click Button    order
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}robot.png  
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}receipt.pdf
    Click Button    order-another

Zip the pdf Directory
    Archive Folder With Zip  ${CURDIR}${/}PDF  ${OUTPUT_DIR}${/}PDF.zip    overwrite=True
Close the browser
    Close Browser
