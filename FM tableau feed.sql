/*SOMETHING IS BEING TRUCATED SO SETTING ANSI WARNING OFF*/
SET  ANSI_WARNINGS OFF

DECLARE @RESULTS TABLE (FMO_REGION VARCHAR(50), DIV VARCHAR(50), JC_WORK_TYPE VARCHAR(50),/* LT_PLANNING_GROUP VARCHAR(50),*/ REPDATE DATETIME, 
/*COUNT_FO INT,*/ CGI INT, COMPLETED INT, NEW_INC INT, PENDING INT, SUM_TTC INT)


  /*SOMETHING IS BEING TRUCATED SO SETTING ANSI WARNING OFF*/
SET ANSI_WARNINGS OFF


 DECLARE @FOTEMP TABLE (
		FO_ID CHAR(10), 
		SP_ID CHAR(10), 
		JOB_CODE CHAR(4),
		COMPL_CODE_1 CHAR(4),
		FO_CREATE_DATE DATETIME,
		FO_COMPL_DATE DATETIME,
     REPDATE DATETIME,
		COMP_YEAR CHAR(4),
		YEAR_MONTH VARCHAR(10),
		TRAVEL_MINUTE BIGINT,
		WORK_MINUTE BIGINT,
		FAS_TIME BIGINT,
		DIV VARCHAR(20),
		FMO_REGION VARCHAR(20),
		CLASS CHAR(3),
		CGI INT,
		JC_Work_Type VARCHAR(50),
		TTC INT,
		MM30dOnTime INT,
		MM65dOnTime INT,
		DUP_ORDER INT)

DECLARE @REPDT   DATETIME
/*set rep date to the first of last month*/
SET @REPDT = DATEADD (MONTH, DATEDIFF (MONTH, 0, GETDATE ()) - 1, 0)
INSERT INTO @FOTEMP
SELECT V.FO_ID,
       V.SP_ID,
       V.JOB_CODE,
       V.COMPL_CODE_1,
       V.FO_CREATE_DATE,
       V.FO_COMPL_DATE,
       @REPDT                                                  AS REPDATE,
       DATEPART (YEAR, V.FO_COMPL_DATE)                        AS COMP_YEAR,
       CONCAT (DATEPART (YEAR, V.FO_COMPL_DATE),
               '_',
               RIGHT ('0' + RTRIM (DATEPART (MM, V.FO_COMPL_DATE)), 2))
          AS YEAR_MONTH,
       V.TRAVEL_MINUTE,
       V.WORK_MINUTE,
       V.TRAVEL_MINUTE + V.WORK_MINUTE                         AS FAS_TIME,
       CASE
          WHEN LEFT (O.OPS_AREA_CD, 1) = 'L' THEN 'Humboldt'
          ELSE O.DIV_NAME
       END
          AS DIV,
       CASE
          WHEN UPPER (O.DIV_NAME) IN ('SAN FRANCISCO',
                                      'SAN JOSE',
                                      'PENINSULA',
                                      'EAST BAY',
                                      'DEANZA',
                                      'DIABLO',
                                      'MISSION')
          THEN
             'Bay Area'
          WHEN UPPER (O.DIV_NAME) IN ('CENTRAL COAST',
                                      'LOS PADRES',
                                      'KERN',
                                      'YOSEMITE',
                                      'FRESNO')
          THEN
             'Central'
          WHEN UPPER (O.DIV_NAME) IN ('NORTH BAY',
                                      'NORTH COAST',
                                      'NORTH VALLEY',
                                      'SACRAMENTO',
                                      'SIERRA',
                                      'STOCKTON')
          THEN
             'Northern'
          ELSE
             'Other'
       END
          AS FMO_REGION,
       CASE right (LEFT (V.TECHNICIAN, 3), 1)
          WHEN 'M' THEN 'EMT'
          WHEN 'Y' THEN 'AMT'
          WHEN 'I' THEN 'MMP'
          WHEN 'G' THEN 'GSR'
          WHEN 'T' THEN 'TMN'
          WHEN '2' THEN 'GSR'
          WHEN '1' THEN 'GSR'
          WHEN 'F' THEN 'FMP'
          WHEN '3' THEN 'GSR'
          WHEN '5' THEN 'GSM'
          WHEN 'D' THEN 'CRR'
          WHEN 'V' THEN 'LMN'
          WHEN 'S' THEN 'SUP'
          WHEN '4' THEN 'DLT'
          WHEN 'Q' THEN 'RMP'
          ELSE 'OTHER'
       END
          AS CLASS,
       CASE WHEN V.COMPL_CODE_1 LIKE ('09%') THEN 1 ELSE 0 END AS CGI,
       /* JC Work Type*/
       CASE
          /*Mark based on comments*/
          WHEN CHARINDEX ('M1315', upper (V.OFFICE_REMARK)) > 0
          THEN
             '2G'
          WHEN    CHARINDEX ('SMOC METER CONNECTOR', UPPER (V.OFFICE_REMARK)) >
                     0
               OR CHARINDEX ('SMOC MATCH', UPPER (V.OFFICE_REMARK)) > 0
          THEN
             'Meter Connector'
          /*WHEN CHARINDEX('NON RES DELAY',UPPER(V.OFFICE_REMARK)) >0 THEN 'NRD'*/

          /*Mark based on JC*/
          WHEN V.JOB_CODE IN ('HDEM',
                              'HDGM',
                              'LDEM',
                              'LDGM')
          THEN
             'Meter Reading'
          WHEN V.JOB_CODE IN ('8430',
                              '8432',
                              '8620',
                              '8622')
          THEN
             '7 Day'
          WHEN V.JOB_CODE IN ('8480', '8482')
          THEN
             '30 Day'
          /* WHEN V.JOB_CODE in ('2140','2142','2143','2144','2146','2148','2149','8350','8590','8592','5235','5236','5237','5238') THEN '65 Day'*/
          WHEN V.JOB_CODE IN ('2140',
                              '2142',
                              '2143',
                              '2144',
                              '2146',
                              '2148',
                              '2149',
                              '8350',
                              '8590',
                              '8592')
          THEN
             '65 Day E'
          WHEN V.JOB_CODE IN ('5235',
                              '5236',
                              '5237',
                              '5238')
          THEN
             '65 Day G'
          WHEN V.JOB_CODE IN ('2020',
                              '2021',
                              '2022',
                              '2026',
                              '2030',
                              '2031',
                              '2032',
                              '2034',
                              '2036',
                              '2038',
                              '2040',
                              '2335',
                              '2635',
                              '2830',
                              '2832',
                              '2834',
                              '2836',
                              '2838',
                              '2840''5060',
                              '5062',
                              '5064',
                              '5066',
                              '5070',
                              '5072',
                              '5074',
                              '5076',
                              '5080',
                              '5082',
                              '5084',
                              '5086',
                              '5190',
                              '5192',
                              '5194',
                              '5196',
                              '5210',
                              '5410',
                              '5765',
                              '7600',
                              '2840',
                              '5870',
                              '5872',
                              '5874',
                              '5876',
                              '5880',
                              '5882',
                              '5884',
                              '5886')
          THEN
             'SM Deployment'
          /*CASE READS JC 2380 & 6370 with comments billing verify*/
          WHEN     V.JOB_CODE IN ('2380', '6370')
               AND CHARINDEX ('BILLING REQUEST', upper (OFFICE_REMARK)) > 0
          THEN
             'Case Reads'
          /*WHEN V.JOB_CODE in ('5239') THEN 'Curb Remediation'*/
          WHEN V.JOB_CODE IN ('2833',
                              '2831',
                              '2835',
                              '2837',
                              '2839',
                              '2841',
                              '5896',
                              '5894',
                              '5890',
                              '5892')
          THEN
             'Opt Out'
          /*WHEN V.JOB_CODE in ('8200') THEN 'ECI'*/
          WHEN V.JOB_CODE IN ('8200',
                              '2100',
                              '2110',
                              '8190',
                              '8210',
                              '5130',
                              '5140')
          THEN
             'ECI'
          WHEN V.JOB_CODE IN ('8680',
                              '8690',
                              '8700',
                              '8701')
          THEN
             'R-Test'
          WHEN V.JOB_CODE IN ('8310')
          THEN
             'UG Inspection'
          WHEN V.JOB_CODE IN ('8230')
          THEN
             'CTM/DA Inspection'
          WHEN     V.JOB_CODE IN ('8750')
               AND CHARINDEX ('PROJECT', upper (OFFICE_REMARK)) > 0
          THEN
             'I-Test Project'
          WHEN V.JOB_CODE IN ('8750')
          THEN
             'I-Test 90d'
          WHEN V.JOB_CODE IN ('2181', '5261')
          THEN
             'Opt Out MM'
          WHEN CHARINDEX ('UPM', upper (OFFICE_REMARK)) > 0
          THEN
             'UPM'
          WHEN     V.JOB_CODE IN ('2000',
                                  '2002',
                                  '2008',
                                  '2011',
                                  '2020',
                                  '2021',
                                  '2022',
                                  '2026',
                                  '2030',
                                  '2031',
                                  '2032',
                                  '2034',
                                  '2036',
                                  '2038',
                                  '2040',
                                  '5062',
                                  '5190',
                                  '5192',
                                  '5194',
                                  '5196',
                                  '5872')
               AND RIGHT (V.MTR_READ_ROUTE, 2) <> 'SM'
          THEN
             'Other ERM2SM'
          WHEN V.JOB_CODE IN ('5260',
                              '5280',
                              '2180',
                              '2200',
                              '5140',
                              '2110',
                              '2190',
                              '8510')
          THEN
             'Chng Party Read/Verify'
          WHEN V.JOB_CODE IN ('8240')
          THEN
             'CTI/PT Install'
          /*Mark based on PM_SO*/
          WHEN V.JOB_CODE IN ('2350',
                              '2351',
                              '2352',
                              '2353',
                              '2354',
                              '2355',
                              '2356',
                              '2357',
                              '2358',
                              '2359',
                              '2360',
                              '2361',
                              '2390',
                              '2391',
                              '2392',
                              '2450',
                              '2451',
                              '2452',
                              '2453',
                              '2454',
                              '2455',
                              '2456',
                              '2457',
                              '2458',
                              '2459',
                              '2460',
                              '2461',
                              '2500',
                              '2501',
                              '2502',
                              '2503',
                              '2504',
                              '2505',
                              '2506',
                              '2507',
                              '2508',
                              '2509',
                              '2510',
                              '2511',
                              '3150',
                              '3170',
                              '7250',
                              '7251',
                              '7260',
                              '7261',
                              '7270',
                              '7271',
                              '7280',
                              '7281',
                              '7290',
                              '7291',
                              '7300',
                              '7301')
          THEN
             'E Start Stop'
          WHEN V.JOB_CODE IN ('2050',
                              '2051',
                              '2052',
                              '2053',
                              '2055',
                              '2056',
                              '2057',
                              '2059',
                              '2060',
                              '2061',
                              '5092',
                              '5094',
                              '5102',
                              '5103',
                              '5104',
                              '5105',
                              '7310',
                              '7311',
                              '7312',
                              '7320',
                              '7321',
                              '7322',
                              '7330',
                              '7331',
                              '7332',
                              '7340',
                              '7341',
                              '7342',
                              '7350',
                              '7351',
                              '7360',
                              '7361',
                              '7390',
                              '7391',
                              '7400',
                              '7401',
                              '7410',
                              '7411',
                              '7412',
                              '7413',
                              '7420',
                              '7421',
                              '7422',
                              '7423',
                              '7430',
                              '7431',
                              '7432',
                              '7433',
                              '8750')
          THEN
             'New Business'
          /*Mark based on MWC*/
          WHEN V.JOB_CODE IN ('2300',
                              '2301',
                              '2302',
                              '2303',
                              '2304',
                              '2305',
                              '2306',
                              '2307',
                              '2308',
                              '2309',
                              '2310',
                              '2311',
                              '2320',
                              '2330',
                              '2600',
                              '2601',
                              '2602',
                              '2603',
                              '2604',
                              '2605',
                              '2606',
                              '2607',
                              '2608',
                              '2609',
                              '2610',
                              '2611',
                              '2620',
                              '2630',
                              '3140',
                              '3160',
                              '3250',
                              '5360',
                              '5400',
                              '5401',
                              '5402',
                              '5403',
                              '5404',
                              '5405',
                              '5406',
                              '5700',
                              '5701',
                              '5702',
                              '5703',
                              '5704',
                              '5705',
                              '5706',
                              '5770',
                              '6360',
                              '7130',
                              '7131',
                              '7132',
                              '7133',
                              '7140',
                              '7141',
                              '7142',
                              '7143',
                              '7150',
                              '7151',
                              '7152',
                              '7153',
                              '7190',
                              '7191',
                              '7192',
                              '7193',
                              '7200',
                              '7201',
                              '7202',
                              '7203',
                              '7210',
                              '7211',
                              '7212',
                              '7213')
          THEN
             'SONP'
          WHEN V.JOB_CODE IN ('2170',
                              '2380',
                              '2550',
                              '2551',
                              '2552',
                              '2553',
                              '2554',
                              '2555',
                              '2556',
                              '2557',
                              '2558',
                              '2559',
                              '2560',
                              '2561',
                              '2650',
                              '2652',
                              '3030',
                              '3110',
                              '5250',
                              '5650',
                              '5651',
                              '5652',
                              '5653',
                              '5654',
                              '5655',
                              '5656',
                              '5780',
                              '6260',
                              '6320',
                              '6370',
                              '7030',
                              '7040',
                              '7041',
                              '7042',
                              '7043',
                              '7050',
                              '7051',
                              '7052',
                              '7053',
                              '7060',
                              '7061',
                              '7062',
                              '7063')
          THEN
             'Broken Lock'
          WHEN MWC = '25'
          THEN
             'Other E  Exch'
          WHEN MWC = 'EY'
          THEN
             'Other E  Maint'
          WHEN MWC = '74'
          THEN
             'Other G  Exch'
          WHEN MWC = 'HY'
          THEN
             'Other G  Maint'
          ELSE
             'Other'
       END
          AS JC_Work_Type,
       datediff (day, V.FO_CREATE_DATE, V.FO_COMPL_DATE)       AS TTC,
       /*Calc Ontime metrict*/
       CASE
          WHEN datediff (day, V.FO_CREATE_DATE, V.FO_COMPL_DATE) > 30 THEN 0
          ELSE 1
       END
          AS MM30dOnTime,
       CASE
          WHEN datediff (day, V.FO_CREATE_DATE, V.FO_COMPL_DATE) > 55 THEN 0
          ELSE 1
       END
          AS MM65dOnTime,
       CASE WHEN LEFT (V.FO_ID, 1) = 'X' THEN 1 ELSE 0 END     AS DUP_ORDER
	  FROM MIB.dbo.V_MSTR_FAS_ORDERS_CMP_FI V
  LEFT JOIN MIB.dbo.V_MWC_FAS_COMP_CD M
           ON  ISNULL(V.COMPL_CODE_1,'0930') = M.comp_cd

  LEFT JOIN MIB.dbo.REF_OPS_AREA_NEW O
          ON V.Office = O.OPS_AREA_CD
		   WHERE V.FO_COMPL_Date between DATEADD(MONTH, -1, @REPDT) and GETDATE()
   and (V.FO_COMPL_Date between m.start_dt and m.end_dt) and V.JOB_CODE not in ('HDEM', 'HDGM', 'LDEM', 'LDGM')
   AND  (right(LEFT(V.TECHNICIAN,3),1) IN ('I','Y','M','F','Q') or V.JOB_CODE in ('2140','2142','2143','2144','2146','2148','2149','8350','8590','8592', '5235','5236','5237','5238'))
   
UNION

/*join the pending data*/
SELECT FO_ID, SP_ID, JOB_CODE, NULL AS COMPL_CODE_1, P.FO_CREATE_DATE, P.FO_COMPL_DATE, @REPDT, NULL AS COMP_YEAR, NULL AS YEAR_MONTH, NULL AS TRAVEL_MINUTE, NULL AS WORK_MINUTE, NULL AS FAS_TIME, DIV_NAME AS DIV, 
       CASE
          WHEN UPPER (DIV_NAME) IN ('SAN FRANCISCO',
                                      'SAN JOSE',
                                      'PENINSULA',
                                      'EAST BAY',
                                      'DEANZA',
                                      'DIABLO',
                                      'MISSION')
          THEN
             'Bay Area'
          WHEN UPPER (DIV_NAME) IN ('CENTRAL COAST',
                                      'LOS PADRES',
                                      'KERN',
                                      'YOSEMITE',
                                      'FRESNO')
          THEN
             'Central'
          WHEN UPPER (DIV_NAME) IN ('NORTH BAY',
                                      'NORTH COAST',
                                      'NORTH VALLEY',
                                      'SACRAMENTO',
                                      'SIERRA',
                                      'STOCKTON')
          THEN
             'Northern'
          ELSE
             'Other'
       END
          AS FMO_REGION,
          SKILL_1 AS CLASS,
          NULL AS CGI,
          JC_Work_Type,
          0 AS TTC,
          NULL AS MM30dOnTime,
          NULL AS MM65dOnTime,
          CASE WHEN LEFT (FO_ID, 1) = 'X' THEN 1 ELSE 0 END     AS DUP_ORDER
FROM RIB.dbo.AJPK_PENDING AS P
WHERE  JOB_CODE not in ('HDEM', 'HDGM', 'LDEM', 'LDGM')

SET  ANSI_WARNINGS ON



WHILE @REPDT <= GETDATE()
  BEGIN
UPDATE @FOTEMP
SET REPDATE = @REPDT
   INSERT INTO @RESULTS
 SELECT 

 FMO_REGION, DIV, JC_WORK_TYPE, /*LT_PLANNING_GROUP,*/ 
 CASE WHEN GETDATE() < EOMONTH(REPDATE) THEN DATEADD(DAY, -1, GETDATE()) ELSE EOMONTH(REPDATE) END RPDATE,
 /*COUNT(FO_ID) AS COUNT_FO,*/
 SUM(CASE WHEN LEFT(COMPL_CODE_1,2)='09' AND FO_COMPL_DATE BETWEEN @REPDT AND EOMONTH(@REPDT) THEN 1 ELSE 0 END) AS CGI, 
      
 SUM(CASE WHEN  LEFT(COMPL_CODE_1,2) NOT IN ('09', '') AND FO_COMPL_DATE BETWEEN @REPDT AND EOMONTH(@REPDT) THEN 1 ELSE 0 END) AS COMPLETED, 
      
 SUM(CASE WHEN FO_CREATE_DATE BETWEEN @REPDT AND EOMONTH(@REPDT) THEN 1 ELSE 0 END) AS NEW_INC,
            
 SUM(CASE WHEN FO_CREATE_DATE <= EOMONTH(@REPDT) AND (FO_COMPL_DATE >= EOMONTH(@REPDT) OR FO_COMPL_DATE IS NULL) THEN 1 ELSE 0 END) AS PENDING, 
      
       SUM(CASE WHEN COMPL_CODE_1 is not null and FO_COMPL_DATE BETWEEN @REPDT AND EOMONTH(@REPDT) THEN TTC ELSE 0 END)  AS SUM_TTC 
       FROM @FOTEMP
     /* WHERE DUP_ORDER = 0*/
      GROUP BY FMO_REGION, DIV, JC_WORK_TYPE, /*LT_PLANNING_GROUP,*/ EOMONTH(REPDATE)
	  
	      SET @REPDT = DATEADD(MONTH,1,@REPDT)
  END
  
  SELECT * FROM @RESULTS