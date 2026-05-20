*============================================================
* PROGRAM : CarFinanceCalc.prg
* PURPOSE : Car Dealership Finance Calculator
*           Calculates Profit, Margin % and Markup % per vehicle
* AUTHOR  : Car Dealership Finance Tool
* VERSION : 1.0
*============================================================

* --- Step 1: Create the sales history table if it does not exist yet ---
IF NOT FILE("CarSales.dbf")
    CREATE TABLE CarSales ;
        (CarModel   C(50), ;
         CostPrice  N(12,2), ;
         SellPrice  N(12,2), ;
         Profit     N(12,2), ;
         MarginPct  N(8,2), ;
         MarkupPct  N(8,2), ;
         SaleDate   D, ;
         SaleStatus C(20))
    * Close the newly created empty table so we can re-open it as an alias
    USE IN SELECT("CarSales")
ENDIF

* --- Step 2: Open the sales history table if it is not already open ---
IF NOT USED("CarSales")
    USE CarSales IN 0 ALIAS CarSales
ENDIF

* --- Step 3: Load sample demo records so the grid shows data on first run ---
SELECT CarSales
IF RECCOUNT("CarSales") = 0
    DO LoadSampleData
ENDIF

* --- Step 4: Build and display the main finance calculator form ---
PUBLIC oFinanceForm
oFinanceForm = CREATEOBJECT("CarFinanceForm")
oFinanceForm.Show(1)   && 1 = modal — program waits here until form closes

* --- Step 5: Clean up when the form is closed ---
IF USED("CarSales")
    USE IN SELECT("CarSales")
ENDIF
RELEASE oFinanceForm

RETURN   && End of main program


*============================================================
* PROCEDURE: LoadSampleData
* Inserts a few demo vehicle records so the grid is not empty
*============================================================
PROCEDURE LoadSampleData
    SELECT CarSales

    INSERT INTO CarSales VALUES ("Toyota Hilux",      280000, 359000, 79000, 22.01, 28.21, DATE()-15, "Profitable sale")
    INSERT INTO CarSales VALUES ("VW Polo 1.0",       185000, 229000, 44000, 19.21, 23.78, DATE()-10, "Profitable sale")
    INSERT INTO CarSales VALUES ("Ford Ranger XLT",   320000, 320000,     0,  0.00,  0.00, DATE()-5,  "Break-even sale")
    INSERT INTO CarSales VALUES ("BMW 3 Series 320i", 490000, 475000,-15000, -3.16, -3.06, DATE()-2,  "Loss sale")
ENDPROC


*============================================================
* CLASS: CarFinanceForm
* The main single-screen finance calculator form
*============================================================
DEFINE CLASS CarFinanceForm AS Form

    Caption    = "Car Dealership Finance Calculator  v1.0"
    Width      = 780
    Height     = 620
    AutoCenter = .T.
    MinButton  = .F.
    MaxButton  = .F.
    BackColor  = RGB(220, 230, 242)   && Soft steel-blue background
    BorderStyle= 2                    && Fixed dialog border

    *----------------------------------------------------------
    * === TITLE BANNER ===
    *----------------------------------------------------------
    ADD OBJECT lblTitle AS Label WITH ;
        Caption   = "CAR DEALERSHIP  —  FINANCE CALCULATOR", ;
        Left      = 20, Top = 10, Width = 740, Height = 30, ;
        FontSize  = 16, FontBold = .T., ;
        ForeColor = RGB(0, 51, 102), ;
        BackStyle = 0, Alignment = 2   && 2 = centred

    ADD OBJECT lblSubTitle AS Label WITH ;
        Caption   = "Calculate profit, margin and markup for each vehicle sale", ;
        Left      = 20, Top = 40, Width = 740, Height = 20, ;
        FontSize  = 9, FontBold = .F., ;
        ForeColor = RGB(80, 80, 100), ;
        BackStyle = 0, Alignment = 2

    *----------------------------------------------------------
    * === INPUT PANEL frame ===
    *----------------------------------------------------------
    ADD OBJECT shpInputPanel AS Shape WITH ;
        Left = 10, Top = 65, Width = 760, Height = 130, ;
        FillColor = RGB(255,255,255), FillStyle = 0, ;
        BorderColor = RGB(100,140,190), BorderWidth = 1

    ADD OBJECT lblPanelTitle AS Label WITH ;
        Caption   = "  Enter Vehicle Details", ;
        Left      = 10, Top = 65, Width = 760, Height = 22, ;
        FontSize  = 10, FontBold = .T., ;
        ForeColor = RGB(255,255,255), ;
        BackColor = RGB(30, 90, 160), BackStyle = 1

    * --- Car Model ---
    ADD OBJECT lblModel AS Label WITH ;
        Caption = "Car Model:", Left = 20, Top = 100, ;
        Width = 90, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtModel AS TextBox WITH ;
        Left = 115, Top = 97, Width = 240, Height = 22, ;
        FontSize = 9, MaxLength = 50, ;
        ToolTipText = "Enter the vehicle model name (e.g. Toyota Hilux)"

    * --- Cost Price ---
    ADD OBJECT lblCostPrice AS Label WITH ;
        Caption = "Cost Price (R):", Left = 375, Top = 100, ;
        Width = 100, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtCostPrice AS TextBox WITH ;
        Left = 480, Top = 97, Width = 130, Height = 22, ;
        FontSize = 9, ;
        ToolTipText = "Enter what the dealership paid for the vehicle"

    * --- Selling Price ---
    ADD OBJECT lblSellPrice AS Label WITH ;
        Caption = "Selling Price (R):", Left = 20, Top = 135, ;
        Width = 110, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtSellPrice AS TextBox WITH ;
        Left = 135, Top = 132, Width = 130, Height = 22, ;
        FontSize = 9, ;
        ToolTipText = "Enter the price at which the vehicle will be sold"

    *----------------------------------------------------------
    * === RESULTS PANEL frame ===
    *----------------------------------------------------------
    ADD OBJECT shpResultsPanel AS Shape WITH ;
        Left = 10, Top = 200, Width = 760, Height = 140, ;
        FillColor = RGB(245,252,245), FillStyle = 0, ;
        BorderColor = RGB(80,160,80), BorderWidth = 1

    ADD OBJECT lblResultsTitle AS Label WITH ;
        Caption   = "  Calculated Results", ;
        Left      = 10, Top = 200, Width = 760, Height = 22, ;
        FontSize  = 10, FontBold = .T., ;
        ForeColor = RGB(255,255,255), ;
        BackColor = RGB(40,130,60), BackStyle = 1

    * --- Profit ---
    ADD OBJECT lblProfitLbl AS Label WITH ;
        Caption = "Profit (R):", Left = 20, Top = 235, ;
        Width = 90, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtProfit AS TextBox WITH ;
        Left = 115, Top = 232, Width = 130, Height = 22, ;
        FontSize = 9, FontBold = .T., ReadOnly = .T., ;
        BackColor = RGB(230,245,230), ;
        ToolTipText = "Profit = Selling Price minus Cost Price"

    * --- Margin % ---
    ADD OBJECT lblMarginLbl AS Label WITH ;
        Caption = "Margin %:", Left = 270, Top = 235, ;
        Width = 75, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtMargin AS TextBox WITH ;
        Left = 350, Top = 232, Width = 110, Height = 22, ;
        FontSize = 9, FontBold = .T., ReadOnly = .T., ;
        BackColor = RGB(230,245,230), ;
        ToolTipText = "Margin % = Profit / Selling Price * 100"

    * --- Markup % ---
    ADD OBJECT lblMarkupLbl AS Label WITH ;
        Caption = "Markup %:", Left = 490, Top = 235, ;
        Width = 75, Height = 20, BackStyle = 0, ;
        FontSize = 9, ForeColor = RGB(30,30,80)

    ADD OBJECT txtMarkup AS TextBox WITH ;
        Left = 570, Top = 232, Width = 110, Height = 22, ;
        FontSize = 9, FontBold = .T., ReadOnly = .T., ;
        BackColor = RGB(230,245,230), ;
        ToolTipText = "Markup % = Profit / Cost Price * 100"

    * --- Status / Result message ---
    ADD OBJECT shpStatus AS Shape WITH ;
        Left = 10, Top = 265, Width = 760, Height = 30, ;
        FillColor = RGB(200,230,200), FillStyle = 0, ;
        BorderColor = RGB(100,180,100), BorderWidth = 1

    ADD OBJECT lblStatus AS Label WITH ;
        Caption   = "  Enter vehicle details above and press Calculate.", ;
        Left      = 12, Top = 268, Width = 756, Height = 26, ;
        FontSize  = 10, FontBold = .T., ;
        ForeColor = RGB(0, 80, 0), BackStyle = 0

    *----------------------------------------------------------
    * === HISTORY GRID PANEL ===
    *----------------------------------------------------------
    ADD OBJECT lblGridTitle AS Label WITH ;
        Caption   = "  Sales History", ;
        Left      = 10, Top = 355, Width = 760, Height = 22, ;
        FontSize  = 10, FontBold = .T., ;
        ForeColor = RGB(255,255,255), ;
        BackColor = RGB(30, 90, 160), BackStyle = 1

    ADD OBJECT grdSalesHistory AS Grid WITH ;
        Left          = 10, ;
        Top           = 377, ;
        Width         = 760, ;
        Height        = 160, ;
        RecordSource  = "CarSales", ;
        ReadOnly      = .T., ;
        GridLines     = 2, ;
        HeaderHeight  = 22, ;
        RowHeight     = 20, ;
        FontSize      = 8, ;
        ColumnCount   = 7

    *----------------------------------------------------------
    * === ACTION BUTTONS ===
    *----------------------------------------------------------
    ADD OBJECT cmdCalculate AS CommandButton WITH ;
        Caption     = "\<Calculate", ;
        Left        = 20,  Top = 548, Width = 110, Height = 30, ;
        FontSize    = 9, FontBold = .T., ;
        BackColor   = RGB(0, 102, 204), ForeColor = RGB(255,255,255), ;
        ToolTipText = "Calculate profit, margin and markup"

    ADD OBJECT cmdClear AS CommandButton WITH ;
        Caption     = "C\<lear", ;
        Left        = 145, Top = 548, Width = 110, Height = 30, ;
        FontSize    = 9, FontBold = .T., ;
        ToolTipText = "Clear all input and result fields"

    ADD OBJECT cmdSave AS CommandButton WITH ;
        Caption     = "\<Save", ;
        Left        = 270, Top = 548, Width = 110, Height = 30, ;
        FontSize    = 9, FontBold = .T., ;
        BackColor   = RGB(0, 153, 51), ForeColor = RGB(255,255,255), ;
        ToolTipText = "Save the current calculation to the history list"

    ADD OBJECT cmdDelete AS CommandButton WITH ;
        Caption     = "\<Delete Selected", ;
        Left        = 395, Top = 548, Width = 140, Height = 30, ;
        FontSize    = 9, FontBold = .T., ;
        BackColor   = RGB(200, 50, 50), ForeColor = RGB(255,255,255), ;
        ToolTipText = "Delete the record selected in the history grid"

    ADD OBJECT cmdExit AS CommandButton WITH ;
        Caption     = "E\<xit", ;
        Left        = 640, Top = 548, Width = 110, Height = 30, ;
        FontSize    = 9, FontBold = .T., ;
        ToolTipText = "Close the Finance Calculator"


    *===========================================================
    * EVENT: Form Init — runs once when the form first opens
    *===========================================================
    PROCEDURE Init
        * Configure grid column headings and widths
        WITH ThisForm.grdSalesHistory
            .Column1.Header1.Caption = "Car Model"
            .Column1.Width           = 160
            .Column1.ControlSource   = "CarSales.CarModel"

            .Column2.Header1.Caption = "Cost Price (R)"
            .Column2.Width           = 100
            .Column2.ControlSource   = "CarSales.CostPrice"

            .Column3.Header1.Caption = "Sell Price (R)"
            .Column3.Width           = 100
            .Column3.ControlSource   = "CarSales.SellPrice"

            .Column4.Header1.Caption = "Profit (R)"
            .Column4.Width           = 100
            .Column4.ControlSource   = "CarSales.Profit"

            .Column5.Header1.Caption = "Margin %"
            .Column5.Width           = 80
            .Column5.ControlSource   = "CarSales.MarginPct"

            .Column6.Header1.Caption = "Markup %"
            .Column6.Width           = 80
            .Column6.ControlSource   = "CarSales.MarkupPct"

            .Column7.Header1.Caption = "Status"
            .Column7.Width           = 120
            .Column7.ControlSource   = "CarSales.SaleStatus"
        ENDWITH

        * Set focus to the first input field
        ThisForm.txtModel.SetFocus
    ENDPROC


    *===========================================================
    * BUTTON: Calculate
    * Validates input and computes Profit, Margin % and Markup %
    *===========================================================
    PROCEDURE cmdCalculate.Click
        * --- Read raw values from the text boxes ---
        LOCAL lcModel, lnCost, lnSell
        LOCAL lnProfit, lnMargin, lnMarkup
        LOCAL lcStatus

        lcModel = ALLTRIM(ThisForm.txtModel.Value)
        lnCost  = VAL(ALLTRIM(ThisForm.txtCostPrice.Value))
        lnSell  = VAL(ALLTRIM(ThisForm.txtSellPrice.Value))

        *------------------------------------------------------
        * VALIDATION 1: Car model must not be blank
        *------------------------------------------------------
        IF EMPTY(lcModel)
            MESSAGEBOX("Please enter a car model name before calculating.", ;
                       48, "Missing Information")
            ThisForm.txtModel.SetFocus
            RETURN
        ENDIF

        *------------------------------------------------------
        * VALIDATION 2: Cost price must be greater than zero
        *------------------------------------------------------
        IF lnCost <= 0
            MESSAGEBOX("Cost Price must be greater than zero." + CHR(13) + ;
                       "Please enter a valid cost price.", ;
                       48, "Invalid Cost Price")
            ThisForm.txtCostPrice.SetFocus
            RETURN
        ENDIF

        *------------------------------------------------------
        * VALIDATION 3: Selling price must be greater than zero
        *------------------------------------------------------
        IF lnSell <= 0
            MESSAGEBOX("Selling Price must be greater than zero." + CHR(13) + ;
                       "Please enter a valid selling price.", ;
                       48, "Invalid Selling Price")
            ThisForm.txtSellPrice.SetFocus
            RETURN
        ENDIF

        *------------------------------------------------------
        * VALIDATION 4: Warn if selling below cost (loss sale)
        *------------------------------------------------------
        IF lnSell < lnCost
            LOCAL lnAnswer
            lnAnswer = MESSAGEBOX( ;
                "WARNING: The selling price is LOWER than the cost price." + CHR(13) + ;
                "This will result in a LOSS sale." + CHR(13) + CHR(13) + ;
                "Do you want to continue and record this as a loss sale?", ;
                36, "Confirm Loss Sale")
            IF lnAnswer = 7   && 7 = No button
                ThisForm.txtSellPrice.SetFocus
                RETURN
            ENDIF
        ENDIF

        *------------------------------------------------------
        * CALCULATIONS
        *------------------------------------------------------
        * Profit = Selling Price minus Cost Price
        lnProfit = lnSell - lnCost

        * Margin % = Profit divided by Selling Price, times 100
        * (how much of every rand sold is profit)
        lnMargin = (lnProfit / lnSell) * 100

        * Markup % = Profit divided by Cost Price, times 100
        * (how much above cost the vehicle is priced)
        lnMarkup = (lnProfit / lnCost) * 100

        *------------------------------------------------------
        * STATUS MESSAGE based on the profit result
        *------------------------------------------------------
        DO CASE
            CASE lnProfit > 0
                lcStatus = "Profitable sale"
            CASE lnProfit = 0
                lcStatus = "Break-even sale"
            OTHERWISE
                lcStatus = "Loss sale"
        ENDCASE

        *------------------------------------------------------
        * Display the calculated results in the result fields
        *------------------------------------------------------
        ThisForm.txtProfit.Value = TRANSFORM(lnProfit,  "999,999,999.99")
        ThisForm.txtMargin.Value = TRANSFORM(lnMargin,  "999.99") + " %"
        ThisForm.txtMarkup.Value = TRANSFORM(lnMarkup,  "999.99") + " %"

        * Update status bar colour and message
        ThisForm.lblStatus.Caption = "  " + lcStatus + ;
            "   |   Profit: R " + TRANSFORM(lnProfit, "999,999,999.99") + ;
            "   |   Margin: " + TRANSFORM(lnMargin, "999.99") + "%" + ;
            "   |   Markup: " + TRANSFORM(lnMarkup, "999.99") + "%"

        DO CASE
            CASE lnProfit > 0
                * Green for a profitable sale
                ThisForm.shpStatus.FillColor = RGB(180, 230, 180)
                ThisForm.lblStatus.ForeColor  = RGB(0, 100, 0)
            CASE lnProfit = 0
                * Amber/orange for break-even
                ThisForm.shpStatus.FillColor = RGB(255, 240, 180)
                ThisForm.lblStatus.ForeColor  = RGB(130, 90, 0)
            OTHERWISE
                * Red for a loss
                ThisForm.shpStatus.FillColor = RGB(255, 200, 200)
                ThisForm.lblStatus.ForeColor  = RGB(160, 0, 0)
        ENDCASE
    ENDPROC


    *===========================================================
    * BUTTON: Clear
    * Resets all input and output fields to blank/zero
    *===========================================================
    PROCEDURE cmdClear.Click
        ThisForm.txtModel.Value     = ""
        ThisForm.txtCostPrice.Value = ""
        ThisForm.txtSellPrice.Value = ""
        ThisForm.txtProfit.Value    = ""
        ThisForm.txtMargin.Value    = ""
        ThisForm.txtMarkup.Value    = ""

        ThisForm.lblStatus.Caption  = "  Enter vehicle details above and press Calculate."
        ThisForm.shpStatus.FillColor = RGB(200, 230, 200)
        ThisForm.lblStatus.ForeColor  = RGB(0, 80, 0)

        ThisForm.txtModel.SetFocus
    ENDPROC


    *===========================================================
    * BUTTON: Save
    * Saves the current calculation into the CarSales history table
    *===========================================================
    PROCEDURE cmdSave.Click
        * --- Guard: make sure the user has actually calculated first ---
        IF EMPTY(ALLTRIM(ThisForm.txtProfit.Value))
            MESSAGEBOX("Please calculate the vehicle finance details first " + ;
                       "before saving.", ;
                       48, "Nothing to Save")
            RETURN
        ENDIF

        * --- Read the values back from the result fields ---
        LOCAL lcModel, lnCost, lnSell, lnProfit, lnMargin, lnMarkup, lcStatus

        lcModel  = ALLTRIM(ThisForm.txtModel.Value)
        lnCost   = VAL(ALLTRIM(ThisForm.txtCostPrice.Value))
        lnSell   = VAL(ALLTRIM(ThisForm.txtSellPrice.Value))

        * Strip currency formatting to recover pure numbers
        lnProfit = VAL(STRTRAN(ALLTRIM(ThisForm.txtProfit.Value), ",", ""))
        lnMargin = VAL(STRTRAN(STRTRAN(ALLTRIM(ThisForm.txtMargin.Value), " %", ""), ",", ""))
        lnMarkup = VAL(STRTRAN(STRTRAN(ALLTRIM(ThisForm.txtMarkup.Value), " %", ""), ",", ""))

        * Derive status from the profit sign
        DO CASE
            CASE lnProfit > 0  :  lcStatus = "Profitable sale"
            CASE lnProfit = 0  :  lcStatus = "Break-even sale"
            OTHERWISE          :  lcStatus = "Loss sale"
        ENDCASE

        * --- Insert the new record into the sales history table ---
        SELECT CarSales
        INSERT INTO CarSales VALUES ;
            (lcModel, lnCost, lnSell, lnProfit, lnMargin, lnMarkup, DATE(), lcStatus)

        * Refresh the grid so the new row is visible
        ThisForm.grdSalesHistory.Refresh

        MESSAGEBOX("Record saved successfully!" + CHR(13) + ;
                   "Vehicle: " + lcModel, ;
                   64, "Record Saved")

        * Clear inputs ready for the next vehicle
        ThisForm.cmdClear.Click
    ENDPROC


    *===========================================================
    * BUTTON: Delete Selected
    * Removes the record that is highlighted in the history grid
    *===========================================================
    PROCEDURE cmdDelete.Click
        SELECT CarSales

        * Guard: nothing to delete if the table is empty
        IF RECCOUNT("CarSales") = 0
            MESSAGEBOX("There are no records in the history list to delete.", ;
                       48, "Nothing to Delete")
            RETURN
        ENDIF

        * Confirm before deleting
        LOCAL lnAnswer, lcModelName
        lcModelName = ALLTRIM(CarSales.CarModel)

        lnAnswer = MESSAGEBOX( ;
            "Are you sure you want to delete the selected record?" + CHR(13) + ;
            "Vehicle: " + lcModelName + CHR(13) + CHR(13) + ;
            "This action cannot be undone.", ;
            36, "Confirm Delete")

        IF lnAnswer = 6   && 6 = Yes
            DELETE             && Mark the current record as deleted
            PACK               && Permanently remove deleted records
            ThisForm.grdSalesHistory.Refresh
            MESSAGEBOX("Record for '" + lcModelName + "' has been deleted.", ;
                       64, "Record Deleted")
        ENDIF
    ENDPROC


    *===========================================================
    * BUTTON: Exit
    * Closes the Finance Calculator form
    *===========================================================
    PROCEDURE cmdExit.Click
        LOCAL lnAnswer
        lnAnswer = MESSAGEBOX( ;
            "Are you sure you want to exit the Finance Calculator?", ;
            36, "Confirm Exit")
        IF lnAnswer = 6   && 6 = Yes button
            ThisForm.Release
            CLEAR EVENTS
        ENDIF
    ENDPROC

ENDDEFINE
*============================================================
* END OF CarFinanceCalc.prg
*============================================================
