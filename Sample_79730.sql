--SWAT-79730 
--by Ran Tao modified 09/02/2015 

USE BIAtlas
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StartDateID INT
DECLARE @StartDate DATETIME
SET @StartDate = '20150101'
SET @StartDateID = YEAR(@StartDate)*10000 + MONTH(@StartDate)*100 + DAY(@StartDate)

--DECLARE @WKhrs INT
--DECLARE @WKdays INT
--SET @WKhrs = 6
--SET @WKdays = 21







--TEST USE ########################################################################################### TEST USE
--#############################################################################################################

--SELECT DisplayName, SRCUserId, UserTitle, StatusCode FROM BIAtlas..UserDim U WHERE U.SRCTeamLeaderUserId = 25716 ORDER BY StatusCode, UserTitle
--SELECT TOP 2000 * FROM BIAtlas..ProductWorkflowRequirementStatusFact
--SELECT TOP 2000 * FROM BIAtlas..WorkflowRequirementDim


--IF OBJECT_ID('tempdb..#RawDataTry') IS NOT NULL DROP TABLE #RawDataTry;

--SELECT	 OTD.SRCOrderDetailId						  AS [OrderDetailID]				
--	,WRD.WorkflowRequirementName
--	,WRD.WorkflowRequirementID							
--	,WSD.WorkflowStatusName							
--	,WFR.ProductWorkflowRequirementStatusFactID		  AS [ID]
--	,U.FirstName + ' ' + U.LastName					  AS [TeamMember]
--	,U.SRCUserID									  AS [UserID]
--	,U.UserTitle		
--	,U.SRCTeamLeaderUserId							  AS [TeamLeaderID] 
--	,TL.FirstName + ' ' + TL.LastName                 AS [TeamLeader]
--	,WFR.WorkflowStatusDateID					
--	,WFR.WorkflowStatusDate						
--	,CASE WHEN RCG.ClientShortName = 'OTHER' THEN CD.ClientName ELSE RCG.ClientShortName       END AS [ClientName]
--	,DATENAME(HOUR,WFR.WorkflowStatusDate)			  AS [Hour]
--	,DATENAME(WEEKDAY,WFR.WorkflowStatusDate)		  AS [DayName]
--	,ROW_NUMBER() OVER(PARTITION BY ODD.SRCOrderDetailID ORDER BY WFR.WorkflowStatusDate ASC)  AS [CompletionStatusSeq]
--	,ROW_NUMBER() OVER(PARTITION BY U.SRCUserID ORDER BY WFR.WorkflowStatusDate ASC)           AS [TMCompletionSeq]
--INTO #RawDataTry	
--FROM BIAtlas..ProductWorkflowRequirementStatusFact WFR
--	JOIN BIAtlas..WorkflowRequirementDim WRD ON WRD.WorkflowRequirementID = WFR.WorkflowRequirementID
--		--AND WRD.WorkflowRequirementTypeCode = 'PURCHASE'
--	JOIN BIAtlas..WorkflowStatusDim WSD ON WSD.WorkflowStatusID = WFR.WorkflowStatusID
--	JOIN BIAtlas..UserDim U ON U.UserID = WFR.WorkflowUserID
--		--AND U.SRCTeamLeaderUserId = 25716 /*Melanie*/ U.UserTitle = 'Auditor, TS' OR 
--		--AND (U.UserTitle in ('Disbursement Analyst', 'Auditor, TS'))
--		--AND (U.UserTitle = 'Purchase Processor' OR U.UserTitle = 'Purchase Liaison' OR U.UserTitle = 'Purchase Escrow Specialist' OR U.UserTitle = 'Disbursement Analyst' OR U.UserTitle = 'Auditor, TS')
--		--AND U.UserTitle NOT LIKE '%INTERN%'
--		--AND U.UserTitle NOT LIKE '%TC%'
--	JOIN BIAtlas..OrderDetailDim ODD ON ODD.OrderDetailID = WFR.OrderDetailID
--		--AND ODD.TransactionTypeCode = 'PURCHASE'
--	JOIN BIAtlas..OrderTransactionDim OTD ON OTD.OrderTransactionID = WFR.OrderTransactionID
--	JOIN BIAtlas..ClientDim CD ON ODD.SRCClientId = CD.SRCClientId
--	LEFT JOIN BIG.[List].[ReportingClientGroupTSI] RCG ON RCG.[SRCClientID] = CD.[ReportingParentID]
--	LEFT JOIN BIAtlas..UserDim TL ON U.SRCTeamLeaderUserId = TL.SRCUserId	
----WHERE WFR.WorkflowStatusID = 4 /*Completed*/
--	--WHERE (WRD.WorkflowRequirementID in (52, 536, 158, 51, 50))
--	WHERE WRD.WorkflowRequirementName LIKE '%audit%'
--	--AND WFR.WorkflowStatusDateID BETWEEN @StartDateID AND @EndDateID
--	--AND WFR.WorkflowStatusDateID > @StartDateID 
--	;

----To check the second priority: function Record Delay and Audit Delay
--SELECT WorkflowRequirementName, WorkflowRequirementID, COUNT(ID) 
--FROM #RawDataTry 
--GROUP BY WorkflowRequirementName, WorkflowRequirementID  
--ORDER BY WorkflowRequirementID;

--#############################################################################################################
--TEST USE ########################################################################################### TEST USE



--ENTIRE COMPANY PERFORMANCE ####################################################### ENTIRE COMPANY PERFORMANCE
--#############################################################################################################

--1. Join tables to get everything we may need ################################################################
--## In this case, as discussed with Melanie, only needed auditing functions are: (level 1) #51, #50, (level 2) #198, #490.
--## Only needed disbursing functions are #52, #536, #158.
--## The #RawData table only contains these 5 functions.
--## This has the entire company's performance.
IF OBJECT_ID('tempdb..#RawData') IS NOT NULL DROP TABLE #RawData;

SELECT	 OTD.SRCOrderDetailId						  AS [OrderDetailID]				
	,WRD.WorkflowRequirementName
	,WRD.WorkflowRequirementID							
	,WSD.WorkflowStatusName							
	,WFR.ProductWorkflowRequirementStatusFactID		  AS [ID]
	,U.FirstName + ' ' + U.LastName					  AS [TeamMember]
	,U.SRCUserID									  AS [UserID]
	,U.UserTitle		
	,U.SRCTeamLeaderUserId							  AS [TeamLeaderID] 
	,TL.FirstName + ' ' + TL.LastName                 AS [TeamLeader]
	,WFR.WorkflowStatusDateID					
	,WFR.WorkflowStatusDate						
	,CASE WHEN RCG.ClientShortName = 'OTHER' THEN CD.ClientName ELSE RCG.ClientShortName       END AS [ClientName]
	,DATENAME(HOUR,WFR.WorkflowStatusDate)			  AS [Hour]
	,DATENAME(WEEKDAY,WFR.WorkflowStatusDate)		  AS [DayName]
	,ROW_NUMBER() OVER(PARTITION BY ODD.SRCOrderDetailID ORDER BY WFR.WorkflowStatusDate ASC)  AS [CompletionStatusSeq]
	,ROW_NUMBER() OVER(PARTITION BY U.SRCUserID ORDER BY WFR.WorkflowStatusDate ASC)           AS [TMCompletionSeq]
INTO #RawData	
FROM BIAtlas..ProductWorkflowRequirementStatusFact WFR
	JOIN BIAtlas..WorkflowRequirementDim WRD ON WRD.WorkflowRequirementID = WFR.WorkflowRequirementID
		--AND WRD.WorkflowRequirementTypeCode = 'PURCHASE'
	JOIN BIAtlas..WorkflowStatusDim WSD ON WSD.WorkflowStatusID = WFR.WorkflowStatusID
	JOIN BIAtlas..UserDim U ON U.UserID = WFR.WorkflowUserID
		--AND U.SRCTeamLeaderUserId = 25716 /*Melanie*/ U.UserTitle = 'Auditor, TS' OR 
		AND (U.UserTitle in ('Disbursement Analyst', 'Auditor, TS'))
		--AND (U.UserTitle = 'Purchase Processor' OR U.UserTitle = 'Purchase Liaison' OR U.UserTitle = 'Purchase Escrow Specialist' OR U.UserTitle = 'Disbursement Analyst' OR U.UserTitle = 'Auditor, TS')
		--AND U.UserTitle NOT LIKE '%INTERN%'
		--AND U.UserTitle NOT LIKE '%TC%'
	JOIN BIAtlas..OrderDetailDim ODD ON ODD.OrderDetailID = WFR.OrderDetailID
		--AND ODD.TransactionTypeCode = 'PURCHASE'
	JOIN BIAtlas..OrderTransactionDim OTD ON OTD.OrderTransactionID = WFR.OrderTransactionID
	JOIN BIAtlas..ClientDim CD ON ODD.SRCClientId = CD.SRCClientId
	LEFT JOIN BIG.[List].[ReportingClientGroupTSI] RCG ON RCG.[SRCClientID] = CD.[ReportingParentID]
	LEFT JOIN BIAtlas..UserDim TL ON U.SRCTeamLeaderUserId = TL.SRCUserId	
--WHERE WFR.WorkflowStatusID = 4 /*Completed*/
	WHERE (WRD.WorkflowRequirementID in (52, 536, 158, 51, 50, 198, 490))
	--WHERE WRD.WorkflowRequirementName LIKE '%delay%'
	--AND WFR.WorkflowStatusDateID BETWEEN @StartDateID AND @EndDateID
	--AND WFR.WorkflowStatusDateID > @StartDateID 
	;

SELECT * FROM #RawData WHERE TeamLeaderId = 25716 ORDER BY UserID;

--2. Merge to itself to get completion turn time, filter high cases ###########################################
--## In this case, I am filtering out all cases lasted for more than 10 hours.
--## The table Turntime contains the turn time of each record.
--## This table has records of all disbursers and auditors.
IF OBJECT_ID('tempdb..#TurnTimeAll') IS NOT NULL DROP TABLE #TurnTimeAll;
SELECT   W.*
	,Z2.WorkflowStatusDate		AS [WorkflowStartDate]
	,(DATEDIFF(SECOND,Z2.WorkflowStatusDate,W.WorkflowStatusDate)*1.00/60)	 AS [CompletionTurnTime(Mins)]
	,Z2.[DayName] As [NextDayName]
INTO #TurnTimeAll
FROM #RawData W
	LEFT JOIN #RawData Z2 
	ON W.TMCompletionSeq = (Z2.TMCompletionSeq+1) 
	AND Z2.UserID = W.UserID 
WHERE  DATEDIFF(SECOND,Z2.WorkflowStatusDate,W.WorkflowStatusDate)*1.00/60 <= 600 and W.[DayName] = Z2.[DayName]  
ORDER BY TeamMember, TMCompletionSeq;

Select * from #TurnTimeALL WHERE TeamLeaderID = 25716;
--ORDER BY WorkflowRequirementName
--WHERE [CompletionTurnTime(Mins)] > 100

--3. Compare on #51 ###########################################################################################
IF OBJECT_ID('tempdb..#TurnTime51') IS NOT NULL DROP TABLE #TurnTime51;
SELECT *
INTO #TurnTime51
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 51

IF OBJECT_ID('tempdb..#Median51') IS NOT NULL DROP TABLE #Median51;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#51) AS [TurnTimeMedian#51]
INTO #Median51
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#51]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime51 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median51 ORDER BY TeamMember;

--4. Compare on #50 ###########################################################################################
IF OBJECT_ID('tempdb..#TurnTime50') IS NOT NULL DROP TABLE #TurnTime50;
SELECT *
INTO #TurnTime50
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 50

IF OBJECT_ID('tempdb..#Median50') IS NOT NULL DROP TABLE #Median50;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#50) AS [TurnTimeMedian#50]
INTO #Median50
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#50]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime50 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median50 ORDER BY TeamMember;

--5. Compare on #52 ###########################################################################################
IF OBJECT_ID('tempdb..#TurnTime52') IS NOT NULL DROP TABLE #TurnTime52;
SELECT *
INTO #TurnTime52
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 52

IF OBJECT_ID('tempdb..#Median52') IS NOT NULL DROP TABLE #Median52;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#52) AS [TurnTimeMedian#52]
INTO #Median52
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#52]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime52 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median52 ORDER BY TeamMember;

--6. Compare on #536 ##########################################################################################
IF OBJECT_ID('tempdb..#TurnTime536') IS NOT NULL DROP TABLE #TurnTime536;
SELECT *
INTO #TurnTime536
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 536

IF OBJECT_ID('tempdb..#Median536') IS NOT NULL DROP TABLE #Median536;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#536) AS [TurnTimeMedian#536]
INTO #Median536
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#536]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime536 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median536 ORDER BY TeamMember;

--7. Compare on #158 ##########################################################################################
IF OBJECT_ID('tempdb..#TurnTime158') IS NOT NULL DROP TABLE #TurnTime158;
SELECT *
INTO #TurnTime158
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 158

IF OBJECT_ID('tempdb..#Median158') IS NOT NULL DROP TABLE #Median158;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#158) AS [TurnTimeMedian#158]
INTO #Median158
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#158]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime158 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median158 ORDER BY TeamMember;

--8. Compare on #198 ##########################################################################################
IF OBJECT_ID('tempdb..#TurnTime198') IS NOT NULL DROP TABLE #TurnTime198;
SELECT *
INTO #TurnTime198
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 198

IF OBJECT_ID('tempdb..#Median198') IS NOT NULL DROP TABLE #Median198;
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#198) AS [TurnTimeMedian#198]
INTO #Median198
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#198]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime198 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median198 ORDER BY TeamMember;

--9. Compare on #490 ##########################################################################################
IF OBJECT_ID('tempdb..#TurnTime490') IS NOT NULL DROP TABLE #TurnTime490;
SELECT *
INTO #TurnTime490
FROM #TurnTimeAll T
WHERE T.WorkflowRequirementID = 490

IF OBJECT_ID('tempdb..#Median490') IS NOT NULL DROP TABLE #Median490; 
SELECT X.TeamMember AS [TeamMember]
	,X.TeamLeaderID
	,AVG(X.TurnTime#490) AS [TurnTimeMedian#490]
INTO #Median490
FROM (SELECT T.TeamMember AS [TeamMember]
		,T.TeamLeaderID
		,T.[CompletionTurnTime(Mins)] AS [TurnTime#490]
		,ROW_NUMBER() OVER (
			PARTITION BY T.TeamMember
			ORDER BY T.[CompletionTurnTime(Mins)]) AS RowNum
		,COUNT(*) OVER (
			PARTITION BY T.TeamMember) AS [RowCount]
	FROM #TurnTime490 T) X
WHERE X.RowNum IN ((X.[RowCount]+1)/2, (X.[RowCount]+2)/2)
GROUP BY X.TeamMember, X.TeamLeaderID
ORDER BY X.TeamMember
;

SELECT * FROM #Median490 ORDER BY TeamMember;

--10. Monthly Functions Count #################################################################################
--## This section is independent from sections above.
--## This section is designed to check the previous volumn of each function every month
--## Then we can combine this with the capacity of the team members to set a team goal
IF OBJECT_ID('tempdb..#MonthVolumn') IS NOT NULL DROP TABLE #MonthVolumn;
SELECT WorkflowRequirementID
	,CAST(LEFT(WorkflowStatusDateID, 6) AS INT) AS [Month] 
	,COUNT(WorkflowStatusDateID) AS [COUNT]
INTO #MonthVolumn
FROM #RawData
WHERE TeamLeaderId = 25716
GROUP BY WorkflowRequirementID
	,CAST(LEFT(WorkflowStatusDateID, 6) AS INT)
ORDER BY WorkflowRequirementID
	,CAST(LEFT(WorkflowStatusDateID, 6) AS INT)
;

--## Then look into function 52, 536, 158, 51, 50, 198, 490 respectively
--## Please see results in excel file
SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 52;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 536;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 158;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 51;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 50;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 198;

SELECT * FROM #MonthVolumn WHERE WorkflowRequirementID = 490;

--#############################################################################################################
--ENTIRE COMPANY PERFORMANCE ####################################################### ENTIRE COMPANY PERFORMANCE



--TEST USE ########################################################################################### TEST USE
--#############################################################################################################

--SELECT * FROM #TurnTime WHERE TeamMember = 'Matt Buxton'

--SELECT *
--FROM #TurnTime
--order by row_number() over(partition by TeamMember order by UserID)

--IF OBJECT_ID('tempdb..#S79730_2') IS NOT NULL DROP TABLE #S79730_2
--SELECT [TeamMember]
--	,[UserID]
--	,SUM(1) AS TotalCase
--	,SUM(convert(int,[Hour])) AS TotalHour
--	INTO #S79730_2
--	FROM (
--		SELECT 
	
--	#S79730_1
--	GROUP BY [TeamMember], [UserID];

--SELECT TOP 1000 * FROM #S79730_1;	

----Filter users who didn't work the whole half a year. Test.

--IF OBJECT_ID('tempdb..#TimeRange_1') IS NOT NULL DROP TABLE #TimeRange_1
--SELECT [TeamMember]
--	,[UserID]
--	, min(WorkflowStatusDateID) as [Earlist]
--	, max(WorkflowStatusDateID) as [Latest]
--INTO #TimeRange_1
--FROM #S79730_1
--GROUP BY [TeamMember], [UserID];

--IF OBJECT_ID('tempdb..#SelectedUser') IS NOT NULL DROP TABLE #SelectedUser
--SELECT UserID 
--INTO #SelectedUser
--FROM #TimeRange_1
--WHERE Earlist < 20150101 and Latest > 20150630;

--IF OBJECT_ID('tempdb..#S79730_2') IS NOT NULL DROP TABLE #S79730_2
--SELECT t.TeamMember
--	,t.UserID
--	,SUM(1) AS TotalCase
--	,SUM(convert(int,t.Hour)) AS TotalHour
--	INTO #S79730_2
--	FROM #S79730_1 t RIGHT JOIN #SelectedUser s
--	ON t.UserID = s.UserID
--	GROUP BY TeamMember, t.UserID;

--SELECT * FROM #S79730_2;

----Double check total case number

--IF OBJECT_ID('tempdb..#S79730_t_1') IS NOT NULL DROP TABLE #S79730_t_1
--SELECT [TeamMember]
--	,[UserID]
--	,SUM(1) AS TotalCase
--	,SUM(convert(int,[Hour])) AS TotalHour
--	INTO #S79730_t_2
--	FROM #TurnTime
--	GROUP BY [TeamMember], [UserID]

--SELECT TeamMember
--	,UserID
--	,TotalCase
--	,TotalHour*1.0/TotalCase AS AverageHour
--	FROM #S79730_t_2

--SELECT DATEDIFF(second, '2009-12-08 09:32:43.863', '2009-12-08 11:49:51.733' );

--SELECT * FROM BIAtlas..UserDim WHERE SRCTeamLeaderUserId is not NULL and LastName = 'Zhang' and FirstName = 'Jiao'; 
--#############################################################################################################
--TEST USE ########################################################################################### TEST USE
