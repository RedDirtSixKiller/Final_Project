/*need this so the stats model works*/
/*add module voltage, model, type, mounting, interval size,*/
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#FO_DATA', 'U') IS NOT NULL
/*Then it exists*/
DROP TABLE #FO_DATA

/*Create a Temp Table to get first FO for a module*/
CREATE TABLE #FO_DATA (ITEM_ID CHAR(10), FO_CREATE_DATE DATETIME)

INSERT INTO #FO_DATA
SELECT M.ITEM_ID,
       MIN (C.FO_CREATE_DATE) AS Min_FO_CREATE_DATE
FROM (
MIB.dbo.MSTR_MODULE M INNER JOIN
MIB.dbo.MSTR_MTR_GAS    G ON (M.MTR_ID = G.MTR_ID)

      INNER JOIN MIB.dbo.MSTR_FAS_ORDERS_NEW N ON (G.SP_ID = N.SP_ID)
      INNER JOIN MIB.dbo.MSTR_FAS_ORDERS_CMP C ON C.FO_ID = N.FO_ID
      )
     
WHERE     [C].[JOB_CODE] IN ('5235',
                              '5236',
                              '5237',
                              '5238')
      AND ([C].[COMPL_CODE_1] IS NOT NULL) and N.FO_CREATE_DATE between M.SET_DT and M.REMOVE_DT
      
      AND ((LEN(C.COMPL_CODE_1)>0
AND LEN(C.FO_COMPL_DATE)>0))     
       OR    (C.COMPL_CODE_1 IS NULL
           AND C.FO_COMPL_DATE IS NULL)
      
GROUP BY M.ITEM_ID, G.MTR_ID, C.SP_ID 




SELECT /*top 50000 g. sp_id, m.item_id,*/

/*Need help here*/
DateDiff(mm, M.SET_DT, Coalesce( #FO_DATA.FO_CREATE_DATE, getdate())) as T,

Case When #FO_DATA.FO_CREATE_DATE is not null then 1 else 0 end as E,



Case When M.MODEL_CD like '%W%' Then 1 else 0 End ExtRange,
Case  When M.MODEL_CD  like  '%S3%' then 1 else 0 End ser3k,
  
  /*Div based binary variables*/
CASE WHEN G.DIV_NAME = 'Central Coast' then 1 else 0 end as CC,
CASE WHEN G.DIV_NAME = 'DeAnza' then 1 else 0 end as Daz,
CASE WHEN G.DIV_NAME = 'Diablo' then 1 else 0 end as Dia,
CASE WHEN G.DIV_NAME = 'East Bay' then 1 else 0 end as EB,
CASE WHEN G.DIV_NAME = 'Fresno' then 1 else 0 end as Fre,
CASE WHEN G.DIV_NAME = 'Kern' then 1 else 0 end as Ker,
CASE WHEN G.DIV_NAME = 'Los Padres' then 1 else 0 end as LP,
CASE WHEN G.DIV_NAME = 'Mission' then 1 else 0 end as Mis,
CASE WHEN G.DIV_NAME = 'North Bay' then 1 else 0 end as NB,
CASE WHEN G.DIV_NAME = 'North Coast' then 1 else 0 end as NC,
CASE WHEN G.DIV_NAME = 'North Valley' then 1 else 0 end as NV,
CASE WHEN G.DIV_NAME = 'Peninsula' then 1 else 0 end as Pen,
CASE WHEN G.DIV_NAME = 'Sacramento' then 1 else 0 end as Sac,
CASE WHEN G.DIV_NAME = 'San Francisco' then 1 else 0 end as SF,
CASE WHEN G.DIV_NAME = 'San Jose' then 1 else 0 end as SJ,
CASE WHEN G.DIV_NAME = 'Sierra' then 1 else 0 end as Sie,
CASE WHEN G.DIV_NAME = 'Stockton' then 1 else 0 end as Stk,
CASE WHEN G.DIV_NAME = 'Yosemite' then 1 else 0 end as Yos,
  
/*Additional Binary Variables*/
CASE WHEN M.MODULE_VOLTAGE = '120' THEN 1 ELSE 0 END AS V120,
CASE WHEN M.MODULE_VOLTAGE IN ('120-240', '240') THEN 1 ELSE 0 END AS V240,
CASE WHEN M.MODULE_VOLTAGE IN ('120-480','480') THEN 1 ELSE 0 END AS V480,

CASE WHEN M.MANUF_CD = 'HX' THEN 1 ELSE 0 END AS MAN_HX,
CASE WHEN M.MANUF_CD = 'SSN' THEN 1 ELSE 0 END AS MAN_SSN,
CASE WHEN M.MANUF_CD = 'DC' THEN 1 ELSE 0 END AS MAN_DC,

CASE WHEN M.INTERVAL_SIZE = 15 THEN 1 ELSE 0 END AS INT_15,
CASE WHEN M.INTERVAL_SIZE = 60 THEN 1 ELSE 0 END AS INT_60,

CASE WHEN M.GAS_MODULE_MOUNTING IS NULL THEN 1 ELSE 0 END AS NORM_MOUNT,
CASE WHEN M.GAS_MODULE_MOUNTING ='BM' THEN 1 ELSE 0 END AS BM_MOUNT,
CASE WHEN M.GAS_MODULE_MOUNTING ='DM' THEN 1 ELSE 0 END AS DM_MOUNT,
CASE WHEN M.GAS_MODULE_MOUNTING ='RM' THEN 1 ELSE 0 END AS RM_MOUNT,
CASE WHEN M.GAS_MODULE_MOUNTING ='SP' THEN 1 ELSE 0 END AS SP_MOUNT,
CASE WHEN M.GAS_MODULE_MOUNTING ='TM' THEN 1 ELSE 0 END AS TM_MOUNT

from MSTR_MTR_GAS G inner join MSTR_MODULE M on G.MTR_ID = M.MTR_ID
LEFT OUTER JOIN #FO_DATA ON M.ITEM_ID = #FO_DATA.ITEM_ID
where G.SMOPTOUT_CD is Null and G.SP_ID is not null AND g.curr_trans_cd = 'S' 
