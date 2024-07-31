select * from (select
    TAB1.LOCATION,
    TAB1.LOCATIONID,
    TAB1.REGISTRATIONNO UHID,
    TAB1.PATIENTIDENTIFIERNUMBER IPID,
    TAB1.OT_PRIORITY,
    TAB1.ADMISSION_FOR,
    TAB1.BILLNO,
    TAB1.PATIENTNAME,
    TAB1.AGE,
    TAB1.GENDER,
    (TAB1.ROOMRENT - coalesce(TAB2.DUALOCCUPANCY,0))ROOMRENT,
    coalesce(TAB2.DUALOCCUPANCY,0)DUALOCCUPANCY,
    ((TAB1.ROOMRENT - coalesce(TAB2.DUALOCCUPANCY,0))+ coalesce(TAB2.DUALOCCUPANCY,0))TOTAL_ROOM_RENT,
    TAB1.NURSING_HOSPITAL_UTILITIES,
    TAB1.NUTRITION_ASSESSMENT_CHARGES,
    TAB1.DRUG_ADMINISTRATION_CHARGES,
    TAB1.SURGICAL_PACKAGE,
    TAB1.CATH_PROCEDURES,
    TAB1.BLOOD_BANK_PROCEDURE,
    TAB1.SURGERIES,
    TAB1.CATHLAB_CONSUMABLES,
    TAB1.OT_CONSUMABLES,
    TAB1.WARD_CONSUMABLES,
    TAB1.LHK_CONSUMABLES,
    TAB1.PROFESSIONAL_CHARGES,
    TAB1.ASSISTANT_DOCTOR_FEE,
    TAB1.ASSISTANT_SURGEON_FEE,
    TAB1.OT_CHARGES,
    TAB1.RECOVERY_CHARGES,
    TAB1.CATHLAB_CHARGES,
    TAB1.MONITORING_CHARGES,
    TAB1.MLC,
    TAB1.DOCUMENTATION_CHARGES,
    TAB1.FOOD_AND_BEVERAGES,
    TAB1.INVESTIGATIONS,
    TAB1.PHYSIOTHERAPY,
    TAB1.LAUNDRY,
    TAB1.MEDICAL_EQUIPMENT,
    TAB1.DOCTOR_CONSULATATION,
    TAB1.PHARMACY,
    TAB1.OT_PHARMACY,
    TAB1.NON_PHARMACY_MATERIAL,
    TAB1.NON_INVASIVE_PACKAGE,
    TAB1.NON_INVASIVE_PROCEDURE,
    TAB1.REHABILITATION,
    TAB1.ADMISSION,
    TAB1.AYURVEDA,
    TAB1.ELECTROTHERAPY,
    TAB1.SPEECH_THERAPY,
    TAB1.EMERGENCY_SERVICE,
    TAB1.ALTERNATIVE_MEDICINE,
    TAB1.PATIENT_PREFERRED_SERVICE,
    TAB1.CSSD,
    TAB1.AMBULANCE_SERVICE,
    TAB1.VACCINATION,
    TAB1.TREATTMENT_MONITORING,
    TAB1.OTHER_CHARGES,
    TAB1.GRANDTOTAL as GRAND_TOTAL,
    TAB1.TOTAL_GST,
    TAB1.DISCOUNT,
    (TAB1.PHARMACY + TAB1.OT_PHARMACY)TOTAL_PHARMACY,
    coalesce(TAB4.IP_PACKAGE_DEAL,0)IP_PACKAGE_DEAL,
    (TAB1.PROFESSIONAL_CHARGES + TAB1.DOCTOR_CONSULATATION)TOTAL_DOCTORFEE,
    coalesce(TAB1.DISCOUNT + TAB1.PHARMACY + TAB1.OT_PHARMACY + TAB1.PROFESSIONAL_CHARGES + TAB1.DOCTOR_CONSULATATION + coalesce(TAB4.IP_PACKAGE_DEAL,
    0),0)TOTALDEDUCTIONS,
    (TAB1.GRANDTOTAL -(TAB1.DISCOUNT + TAB1.PHARMACY + TAB1.OT_PHARMACY + TAB1.PROFESSIONAL_CHARGES + TAB1.DOCTOR_CONSULATATION + coalesce(TAB4.IP_PACKAGE_DEAL,
    0)))NETREVENUE,
    TAB1.SPECIALISATION,
    TAB1.DOCTORID as PRIMARYDOCTORID,
    TAB1.DOCTORNAME PRIMARY_CONSULTANT,
    TAB1.DOCTORID1 as SECONDARYDOCTORID,
    TAB1.DOCTORNAME_2 as SECONDARY_CONSULTANT,
    TAB1.SPECIALITY_2 as SPECIALITY,
    TAB1.BEDTYPE,
    (select
        UPPER(AG.AGREEMENTNAME)
    from
        BILLING.PATIENTBILL PB,
        CRM.VWR_AGREEMENTS AG
    where
        AG.AGREEMENTID = PB.AGGREMENTID
        and PB.LOCATIONID = AG.LOCATIONID
        and PB.BILLNO = TAB1.BILLNO)as AGREEMENTNAME,
    TAB1.COMPANYTYPE,
    TAB1.COMPANY,
    TAB1.ADMITDATETIME,
    /* MIS.F_GETBEDCATEGORY_AUDIT (TAB1.PATIENTIDENTIFIERNUMBER,
TAB1.ADMITDATETIME) AS ADMITTEDBEDCATEGORY,*/
    (select
        distinct (BCM.CATEGORYNAME)
    from
        ADT.BEDCATEGORYMASTER BCM
    where
        BCM.CATEGORYID in
    (select
            BM.CATEGORYID
        from
            ADT.BEDMASTER BM
        where
            BM.BEDID in
        (select
                MAX(BA.BEDID)
            from
                ADT.INPATIENTMASTER IPM1,
                ADT.BEDADMISSION BA
            where
                IPM1.INPATIENTID = BA.INPATIENTID
                and IPM1.INPATIENTNO = TAB1.PATIENTIDENTIFIERNUMBER
                and date(BA.STARTDATE)<= date(TAB1.ADMITDATETIME)
                    and(case
                        when BA.ENDDATE is null then date(clock_timestamp()::timestamp)
                        else date(BA.ENDDATE)
                    end)>= TAB1.ADMITDATETIME)))as ADMITTEDBEDCATEGORY,
    TAB1.BILLDATE,
    TAB1.DISCHARGEDATETIME,
    TAB1.CITYNAME CITY,
    TAB1.DISTRICTNAME DISTRICT,
    TAB1.STATENAME STATE,
    TAB1.COUNTRYTYPE COUNTRY,
    --TAB1.WARD,
    TAB1.SURGEON_FEES,
    TAB1.ANAESTHESIOLOGIST_FEES,
    TAB1.ASSISTANT_SURGEON_FEES,
    TAB1.IP_VISIT_CHARGES,
    TAB1.OTHER_DOCTORFEE,
    TAB5.IP_PACKAGE_DOCTORFEES,
    (select
        (case
            when PB4.CURRENCYCODE = 'USD' then 'DOLLAR'
            else 'INR'
        end)
    from
        BILLING.PATIENTBILL PB4
    where
        PB4.PATIENTIDENTIFIERNUMBER = TAB1.PATIENTIDENTIFIERNUMBER
        and PB4.PATIENTSERVICE = 3)as BILLCATEGORY,
    (select
        PB4.CURRENCYCODE
    from
        BILLING.PATIENTBILL PB4
    where
        PB4.PATIENTIDENTIFIERNUMBER = TAB1.PATIENTIDENTIFIERNUMBER
        and PB4.PATIENTSERVICE = 3)as CURRENCY,
    (select
        PB4.CONVERSIONRATE
    from
        BILLING.PATIENTBILL PB4
    where
        PB4.PATIENTIDENTIFIERNUMBER = TAB1.PATIENTIDENTIFIERNUMBER
        and PB4.PATIENTSERVICE = 3)as CONVERSIONRATE,
    case
        when(select
            UPPER(AG.AGREEMENTNAME)
        from
            BILLING.PATIENTBILL PB,
            CRM.VWR_AGREEMENTS AG
        where
            AG.AGREEMENTID = PB.AGGREMENTID
            and PB.LOCATIONID = AG.LOCATIONID
            and PB.BILLNO = TAB1.BILLNO)is null then ('&amp;' || TAB1.COMPANY)
        else(select
            (UPPER(AG.AGREEMENTNAME)|| '&amp;' || TAB1.COMPANY)
        from
            BILLING.PATIENTBILL PB,
            CRM.VWR_AGREEMENTS AG
        where
            AG.AGREEMENTID = PB.AGGREMENTID
            and PB.LOCATIONID = AG.LOCATIONID
            and PB.BILLNO = TAB1.BILLNO)
    end CUSTAGREEMENT
from
    (select
        distinct TAB.LOCATION,
        TAB.LOCATIONID,
        TAB.REGISTRATIONNO,
        TAB.PATIENTIDENTIFIERNUMBER,
        (select
            MAX(coalesce(UPPER(KLD.LOVDETAILVALUE),''))
        from
            OT.OT_PROC_REQ_HDR HDR
        inner join OT.OT_LOVDETAIL KLD on KLD.LOVDETAILID = HDR.REQUEST_PRIORITY_ID
        where
            HDR.IP_NUMBER = TAB.PATIENTIDENTIFIERNUMBER)as OT_PRIORITY,
        (select
            coalesce(UPPER(LD.LOVDETAILVALUE),'')
        from
            ADT.INPATIENTMASTER A
        inner join EHIS.VWR_LOVDETAIL LD on A.ADMISSIONFOR = LD.LOVDETAILID
        where
            A.ADMISSIONFOR > 0
            and A.STATUS <> 0
            and A.INPATIENTNO = TAB.PATIENTIDENTIFIERNUMBER)as ADMISSION_FOR,
        TAB.BILLNO,
        TAB.PATIENTNAME,
        TAB.AGE,
        TAB.SEX GENDER,
        null as "ADDITIONALITEMS",
        null as "BLOODRESERVATIONS",
        coalesce(SUM((case when TAB.SERVICETYPEID = 181 then coalesce(TAB.TOTAL,0)end)),0) as CATHLAB_CONSUMABLES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 19 then coalesce(TAB.TOTAL,0)end)),0) as CATH_PROCEDURES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 182 then coalesce(TAB.TOTAL,0)end)),0) as OT_CONSUMABLES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 26 then coalesce(TAB.TOTAL,0)end)),0) as MLC,
        coalesce(SUM((case when TAB.SERVICETYPEID in(22,9)then coalesce(TAB.TOTAL,0)end)),0)as DOCUMENTATION_CHARGES,
        null as "EMERGENCYPROFCHARGE",
        null as "EXTRACATHCONSUMABLES",
        coalesce(SUM((case when TAB.SERVICETYPEID = 201 then coalesce(TAB.TOTAL,0)end)),0) as FOOD_AND_BEVERAGES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 183 then coalesce(TAB.TOTAL,0)end)),0) as WARD_CONSUMABLES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(1,3)then coalesce(TAB.TOTAL,0)end)),0) as INVESTIGATIONS,
        coalesce(SUM((case when TAB.SERVICETYPEID = 17 then coalesce(TAB.TOTAL,0)end)),0) as LAUNDRY,
        coalesce(SUM((case when TAB.SERVICETYPEID = 4 then coalesce(TAB.TOTAL,0)end)),0) as MEDICAL_EQUIPMENT,
        null as "MEDICAL_EQUIPMENT_OT",
        null as "MISCELLANEOUS",
        null as "PHARMACYRETURNS",
        coalesce(SUM((case when TAB.SERVICETYPEID = 2 then coalesce(TAB.TOTAL,0)end)),0) as PHYSIOTHERAPY,
        null as "PLASMAPHERESIS",
        null as "PLATELETTE",
        null as "RADIOTHERAPHY",
        TAB.ROOMOCCUPANCY as "ROOMOCCUPANCY",
        coalesce(SUM((case when TAB.SERVICETYPEID = 5 then coalesce(TAB.TOTAL,0)end)),0) as ROOMRENT,
        null as "SCREENINGCHARGES",
        null as "SPECIALNURSING",
        coalesce(SUM(case when TAB.SERVICETYPEID in(19,12)then coalesce(TAB.TOTAL,0)end),0) as SURGERIES,
        null as "TV",
        null as "TELEPHONECALLS",
        coalesce(SUM((case when(TAB.SERVICETYPEID in(161)and TAB.SERVICEID not in(14084,18782))then coalesce(TAB.TOTAL,
                                                                                0)end)),0) as DOCTOR_CONSULATATION,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6)then coalesce(TAB.TOTAL,0)end)),0)as PROFESSIONAL_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(300,302,303,24,31)then coalesce(TAB.TOTAL,0)end)),0) as PHARMACY,
        coalesce(SUM((case when TAB.SERVICETYPEID = 301 then coalesce(TAB.TOTAL,0)end)),0) as OT_PHARMACY,
        coalesce(SUM((case when TAB.SERVICETYPEID = 7 then coalesce(TAB.TOTAL,0)end)),0)NON_INVASIVE_PACKAGE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 10 then coalesce(TAB.TOTAL,0)end)),0)NON_INVASIVE_PROCEDURE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 13 then coalesce(TAB.TOTAL,0)end)),0)REHABILITATION,
        coalesce(SUM((case when TAB.SERVICETYPEID = 14 then coalesce(TAB.TOTAL,0)end)),0)ADMISSION,
        coalesce(SUM((case when TAB.SERVICETYPEID = 15 then coalesce(TAB.TOTAL,0)end)),0)AYURVEDA,
        coalesce(SUM((case when TAB.SERVICETYPEID = 16 then coalesce(TAB.TOTAL,0)end)),0)ELECTROTHERAPY,
        coalesce(SUM((case when TAB.SERVICETYPEID = 18 then coalesce(TAB.TOTAL,0)end)),0)SPEECH_THERAPY,
        coalesce(SUM((case when TAB.SERVICETYPEID = 20 then coalesce(TAB.TOTAL,0)end)),0)EMERGENCY_SERVICE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 21 then coalesce(TAB.TOTAL,0)end)),0)ALTERNATIVE_MEDICINE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 23 then coalesce(TAB.TOTAL,0)end)),0)PATIENT_PREFERRED_SERVICE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 25 then coalesce(TAB.TOTAL,0)end)),0)NURSING_HOSPITAL_UTILITIES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 930 then coalesce(TAB.TOTAL,0)end)),0)TREATTMENT_MONITORING,
        coalesce(SUM((case when TAB.SERVICETYPEID = 27 then coalesce(TAB.TOTAL,0)end)),0)NUTRITION_ASSESSMENT_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 28 then coalesce(TAB.TOTAL,0)end)),0)DRUG_ADMINISTRATION_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 29 then coalesce(TAB.TOTAL,0)end)),0)ASSISTANT_DOCTOR_FEE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 30 then coalesce(TAB.TOTAL,0)end)),0)ASSISTANT_SURGEON_FEE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 32 then coalesce(TAB.TOTAL,0)end)),0)CONSUMABLES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 144 then coalesce(TAB.TOTAL,0)end)),0)SURGICAL_PACKAGE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 184 then coalesce(TAB.TOTAL,0)end)),0)NON_PHARMACY_MATERIAL,
        coalesce(SUM((case when TAB.SERVICETYPEID = 202 and TAB.SERVICEID <> 8875 then coalesce(TAB.TOTAL,
                                                                                0)end)),0)OT_CHARGES,
        coalesce(SUM((case when TAB.SERVICEID = 8875 then coalesce(TAB.TOTAL,0)end)),0)RECOVERY_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 341 then coalesce(TAB.TOTAL,0)end)),0)CSSD,
        coalesce(SUM((case when TAB.SERVICETYPEID = 421 then coalesce(TAB.TOTAL,0)end)),0)AMBULANCE_SERVICE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 502 then coalesce(TAB.TOTAL,0)end)),0)VACCINATION,
        coalesce(SUM((case when TAB.SERVICETYPEID = 504 then coalesce(TAB.TOTAL,0)end)),0)CATHLAB_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 506 then coalesce(TAB.TOTAL,0)end)),0)BLOOD_BANK_PROCEDURE,
        coalesce(SUM((case when TAB.SERVICETYPEID = 508 then coalesce(TAB.TOTAL,0)end)),0)LHK_CONSUMABLES,
        coalesce(SUM((case when TAB.SERVICETYPEID = 509 then coalesce(TAB.TOTAL,0)end)),0)MONITORING_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6,161)and TAB.SERVICEID = 2121 then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as SURGEON_FEES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6,161)and TAB.SERVICEID = 2122 then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as ANAESTHESIOLOGIST_FEES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6,161)and TAB.SERVICEID = 2123 then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as ASSISTANT_SURGEON_FEES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6,161)and TAB.SERVICEID = 2117 then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as IP_VISIT_CHARGES,
        coalesce(SUM((case when TAB.SERVICETYPEID in(6,161)and TAB.SERVICEID not in(2121,2123,2122,2117)then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as OTHER_DOCTORFEE,
        coalesce(SUM((case when TAB.SERVICETYPEID in(8,304,321,503,505,548,549,569,609,629,649,669,670,671,672,
                    691,709,710,730,750,770,790,810,830,850,870,890,910,950,951,970,990,1010,1011,1012,1013,1014,
                    1015,1035,1036,1055,1075,1095,1115,1135,1155,1156,1157,1175,1195,1215,1235,1236)then coalesce(TAB.TOTAL,
                                                                                0)end)),0)as OTHER_CHARGES,
        SUM(TAB.TOTAL)as GRANDTOTAL,
        TAB.TOTAL_GST,
        TAB.DISCOUNTAMOUNT DISCOUNT,
        TAB.SPECIALITY_NAME as SPECIALISATION,
        TAB.DOCTORID,
        TAB.DOCTORID1,
        TAB.DOCTORNAME,
        TAB.DOCTORNAME1 as DOCTORNAME_2,
        TAB.SPECIALITY_NAME1 as SPECIALITY_2,
        MIS.F_BEDCATEGORYNAME(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID::numeric) as BEDTYPE,
        coalesce(MIS.F_IPBILL_CUSTTYPE(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID),'OTHERS')COMPANYTYPE,
        coalesce(MIS.F_GETCUSTOMERNAME1(tab.PATIENTIDENTIFIERNUMBER,tab.REGISTRATIONNO),'CASH')COMPANY,
        TAB.DATEOFADMISSION as ADMITDATETIME,
        TAB.BILLDATE,
        TAB.DISCHARGEDATE as DISCHARGEDATETIME,
        TAB.CITYNAME,
        TAB.DISTRICTNAME,
        TAB.STATENAME,
        TAB.COUNTRYTYPE,
        TAB.WARD
    from
        (with tab as ( select PB.LOCATIONID,
            PB.REGISTRATIONNO,
            PB.PATIENTIDENTIFIERNUMBER,
            PB.BILLNO,
            PB.PATIENTNAME,
            PB.PATIENTSERVICE,
            PB.BILLINGTYPEID,
            PB.DISCOUNTAMOUNT,
            PB.TOTALBILLAMOUNT,
            coalesce(PB.TOTAL_GST,0)TOTAL_GST,
            PB.TOTALSERVICEAMOUNT,
            PB.BILLDATE as BILLDATE,
            PB.PRIMARYPAYERID,
            PB.PRIMARYDOCTORID
            from billing.patientbill pb where
            date(PB.BILLDATE) between date('2024-01-01') and date('2024-04-30')
                and PB.LOCATIONID in('10551')
                    and PB.DELFLAG = 1)

select
            distinct EHS.LEVELDETAILNAME location,
            tab.LOCATIONID,
            tab.REGISTRATIONNO,
            tab.PATIENTIDENTIFIERNUMBER,
            tab.BILLNO,
            tab.PATIENTNAME,
            (trunc( public.months_between(clock_timestamp()::timestamp,P.BIRTHDATE)/ 12))AGE,
            case
                P.GENDER when '71' then 'FEMALE'
                when '72' then 'MALE'
            end SEX,
            (select
                ROUND(extract (EPOCH
            from
                (coalesce(MAX(IP.ENDDATETIME),clock_timestamp()::timestamp)- MIN(IP.STARTDATETIME))))
            from
                BILLING.IPBEDDETAILS IP
            where
                IP.IPNO = tab.PATIENTIDENTIFIERNUMBER)as ROOMOCCUPANCY,
            EMD.FIRSTNAME || ' ' || coalesce(EMD.MIDDLENAME,null,'') || ' ' || coalesce(EMD.LASTNAME,null,'') as DOCTORNAME,
            SPM.SPECIALITY_NAME,
            EMD.EMPLOYEEID as DOCTORID,
            EMD1.EMPLOYEEID as DOCTORID1,
            EMD1.FIRSTNAME || ' ' || coalesce(EMD1.MIDDLENAME,null,'') || ' ' || coalesce(EMD1.LASTNAME,null,'') as DOCTORNAME1,
            SPM1.SPECIALITY_NAME as SPECIALITY_NAME1,
            coalesce(SUM(PBD.INDIVIDUALRATE),0)TOTAL,
            PBD.SERVICEID,
            ST.SERVICETYPENAME,
            ST.SERVICETYPEID,
            tab.PATIENTSERVICE,
            tab.BILLINGTYPEID,
            PBD.DEPTID,
            tab.DISCOUNTAMOUNT,
            tab.TOTALBILLAMOUNT,
            tab.TOTAL_GST,
            tab.TOTALSERVICEAMOUNT,
--            MIS.F_BEDCATEGORYNAME(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID::numeric) as BEDTYPE,
--            coalesce(MIS.F_IPBILL_CUSTTYPE(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID),'OTHERS')COMPANYTYPE,
--            coalesce(MIS.F_GETCUSTOMERNAME1(tab.PATIENTIDENTIFIERNUMBER,tab.REGISTRATIONNO),'CASH')COMPANY,
            IPM.DATEOFADMISSION as DATEOFADMISSION,
            tab.BILLDATE,
            AD.DISCHARGEINITIATEDDATETIME as DISCHARGEDATE,
            (select
                distinct UPPER(C.CITYNAME)
            from
                EHIS.VWR_CITYMASTER C,
                REGISTRATION.ADDRESSMASTER ADM
            where
                C.CITYID = ADM.CITY
                and C.DISTRICTID = ADM.DISTRICT
                and C.STATEID = ADM.STATE
                and ADM.REGISTRATIONID = P.REGISTRATIONID
                and C.DISTRICTID = ADM.DISTRICT
                and ADM.ADDRESSTYPEID = 2)CITYNAME,
            (select
                distinct UPPER(DDD.DISTRICTNAME)
            from
                EHIS.VWR_DISTRICTMASTER DDD,
                REGISTRATION.ADDRESSMASTER ADM
            where
                DDD.DISTRICTID = ADM.DISTRICT
                and ADM.REGISTRATIONID = P.REGISTRATIONID
                and DDD.STATEID = ADM.STATE
                and ADM.ADDRESSTYPEID = 2)DISTRICTNAME,
            (select
                distinct UPPER(ST.STATENAME)
            from
                EHIS.VWR_STATEMASTER ST,
                REGISTRATION.ADDRESSMASTER ADM
            where
                ST.STATEID = ADM.STATE
                and ADM.REGISTRATIONID = P.REGISTRATIONID
                and ST.COUNTRYID = ADM.COUNTRY
                and ADM.ADDRESSTYPEID = 2)STATENAME,
            (select
                distinct UPPER(CO.COUNTRYTYPE)
            from
                EHIS.VWR_COUNTRYMASTER CO,
                REGISTRATION.ADDRESSMASTER ADM
            where
                CO.COUNTRYID = ADM.COUNTRY
                and ADM.REGISTRATIONID = P.REGISTRATIONID
                and ADM.ADDRESSTYPEID = 2)COUNTRYTYPE,
             MIS.F_WARDNAME_FORDISCHARGES(tab.PATIENTIDENTIFIERNUMBER)WARD
        from tab 
        join BILLING.PATIENTBILLDETAILS PBD on PBD.BILLNO = tab.BILLNO
        left outer join HR.MV_EMPLOYEE_MAIN_DETAILS EMD on tab.PRIMARYDOCTORID = EMD.EMPLOYEEID
        left outer join EHIS.VWR_SPECIALITYMASTER SPM on SPM.SPECIALITY_ID = EMD.SPECIALITYID
        join BILLING.VWR_SERVICETYPE ST on ST.SERVICETYPEID = PBD.SERVICETYPEID
        join REGISTRATION.PATIENT P on P.UHID = tab.REGISTRATIONNO
        join ADT.INPATIENTMASTER IPM on IPM.INPATIENTNO = tab.PATIENTIDENTIFIERNUMBER
        left outer join HR.MV_EMPLOYEE_MAIN_DETAILS EMD1 on IPM.SECONDADMITTINGDOCTOR = EMD1.EMPLOYEEID
        left outer join EHIS.VWR_SPECIALITYMASTER SPM1 on SPM1.SPECIALITY_ID = EMD1.SPECIALITYID
        join WARDS.ADMISSIONDETAILS AD on AD.IPNUMBER = tab.PATIENTIDENTIFIERNUMBER
        join EHIS.VWR_COA_STRUCT_DETAILS EHS on EHS.CHARTID = tab.LOCATIONID  
where
1=1
                group by
                    EHS.LEVELDETAILNAME,
                    tab.LOCATIONID,
                    tab.REGISTRATIONNO,
                    tab.PATIENTIDENTIFIERNUMBER,
                    tab.BILLNO,
                    tab.PATIENTNAME,
                    EMD.FIRSTNAME || ' ' || coalesce(EMD.MIDDLENAME,null,'') || ' ' || coalesce(EMD.LASTNAME,null,''),
                    EMD.EMPLOYEEID,
                    EMD1.EMPLOYEEID,
                    SPM.SPECIALITY_NAME,
                    ST.SERVICETYPENAME,
                    tab.BILLDATE,
                    PBD.SERVICEID,
                    ST.SERVICETYPEID,
                    tab.PATIENTSERVICE,
                    PBD.DEPTID,
                    P.BIRTHDATE,
                    EMD1.FIRSTNAME,
                    EMD1.MIDDLENAME,
                    EMD1.LASTNAME,
                    SPM1.SPECIALITY_NAME,
                    tab.DISCOUNTAMOUNT,
                    tab.TOTALBILLAMOUNT,
                    tab.TOTAL_GST,
                    tab.TOTALSERVICEAMOUNT,
                    tab.BILLINGTYPEID,
                    date_trunc('day',clock_timestamp()::timestamp - P.BIRTHDATE),
                    case
                        P.GENDER when '71' then 'FEMALE'
                        when '72' then 'MALE'
                    end ,
                    tab.TOTALBILLAMOUNT,
                    tab.TOTALSERVICEAMOUNT,
--                    MIS.F_BEDCATEGORYNAME(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID::numeric),
--                    coalesce(MIS.F_IPBILL_CUSTTYPE(tab.PATIENTIDENTIFIERNUMBER,tab.LOCATIONID),'OTHERS'),
--                    coalesce(MIS.F_GETCUSTOMERNAME1(tab.PATIENTIDENTIFIERNUMBER,tab.REGISTRATIONNO),'CASH'),
                    IPM.DATEOFADMISSION,
                    tab.BILLDATE,
                    AD.DISCHARGEINITIATEDDATETIME,
                    P.REGISTRATIONID
                    --, MIS.F_WARDNAME_FORDISCHARGES(PB.PATIENTIDENTIFIERNUMBER)
                order by
                    1)TAB
    group by
        TAB.LOCATION,
        TAB.LOCATIONID,
        TAB.REGISTRATIONNO,
        TAB.PATIENTIDENTIFIERNUMBER,
        TAB.BILLNO,
        TAB.PATIENTNAME,
        TAB.AGE,
        TAB.SEX,
        TAB.DOCTORNAME1,
        TAB.SPECIALITY_NAME1,
        TAB.DISCOUNTAMOUNT,
        TAB.TOTAL_GST,
        TAB.ROOMOCCUPANCY,
        TAB.SPECIALITY_NAME,
        TAB.DOCTORNAME,
        TAB.DOCTORID,
        TAB.DOCTORID1,
--        TAB.BEDTYPE,
--        TAB.COMPANYTYPE,
--        TAB.COMPANY,
        TAB.BILLDATE,
        TAB.DATEOFADMISSION,
        TAB.DISCHARGEDATE,
        TAB.CITYNAME,
        TAB.DISTRICTNAME,
        TAB.STATENAME,
        TAB.COUNTRYTYPE,
        TAB.WARD)TAB1
left join
    (select
        TAB.IPNO,
        TAB.BILLNO,
        SUM(DURATION * DUALOCCUPANCY)DUALOCCUPANCY
    from
        (select
            IP.IPNO,
            PB.BILLNO,
            IP.BILLABLEBEDCATEGORYID BED,
            ROUND(extract(EPOCH
        from
            coalesce(MAX(IP.ENDDATETIME),
            clock_timestamp()::timestamp)- MIN(IP.STARTDATETIME)))DURATION,
            (ROUND(mis.F_GETSERVICEITEMTARIFF(DOM.location::text,coalesce(PPD.AGGREMENTID,0),IP.BILLABLEBEDCATEGORYID,
            3,null,
            coalesce(PPD.CUSTOMERID,0),null,2127,null,null,null,PPD.RELATIONSHIPID),2)* DOM.TARIFF)DUALOCCUPANCY
        from
            BILLING.IPBEDDETAILS IP
        right join BILLING.PATIENTBILL PB on PB.PATIENTIDENTIFIERNUMBER = IP.IPNO
        right join BILLING.PATIENTPOLICYMASTER PPM on PPM.REGISTRATIONNO = IP.REGISTRATIONNO
        left join BILLING.PATEINTPOLICYDETAILS PPD on PPM.PATIENTPOLICYMASTERID = PPD.POLICYMASTERID,
            BILLING.DUALOCCUPANCYMASTER DOM,
            ehis.VWR_coa_struct_details ehs
        where
            IP.BILLABLEBEDCATEGORYID = DOM.BEDCATEGORYID
            and DOM.LOCATION in('10551')
                and IP.PATIENTOCCUPANCY = '0'
                --AND PB.PATIENTIDENTIFIERNUMBER(+)= IP.IPNO
                --AND PPM.REGISTRATIONNO(+)= IP.REGISTRATIONNO
                --AND PPM.PATIENTPOLICYMASTERID = PPD.POLICYMASTERID(+)
            group by
                IP.IPNO,
                IP.BILLABLEBEDCATEGORYID,
                DOM.TARIFF,
                PB.BILLNO,
                DOM.LOCATION,
                PPD.AGGREMENTID,
                PPD.CUSTOMERID,
                PPD.RELATIONSHIPID)TAB
    where
        TAB.BILLNO is not null
    group by
        TAB.IPNO,
        TAB.BILLNO)TAB2 on TAB1.BILLNO = TAB2.BILLNO
left join
    (select
        T.BILLNO,
        SUM(T.TRANAMOUNT)REFUND
    from
        BILLING.TRANSACTION T,
        BILLING.PATIENTBILL P
    where
        T.LOCATIONID = P.LOCATIONID
        and T.BILLNO = P.BILLNO
        and P.LOCATIONID in('10551')
            --and date_trunc('day',P.BILLDATE)between '2024-04-01' and '2024-04-30'
        and date(P.BILLDATE) between date('2024-01-01') and date('2024-04-30')
                and T.TRANEVENT::numeric in(25)
                    and T.TRANTYPE = 'CR'
                    and P.PATIENTSERVICE = 3
                group by
                    T.BILLNO)TAB3 on TAB1.BILLNO = TAB3.BILLNO
left join
    (select
        PBD.BILLNO,
        SUM(PBD.AMOUNTLIMIT)IP_PACKAGE_DEAL
    from
        BILLING.PATIENTBILL P,
        BILLING.PACKAGEBILLDETAILS PBD
    where
        PBD.SERVICETYPEID in(300,301,302,303,24,31)
            and P.BILLNO = PBD.BILLNO
            and P.PATIENTSERVICE = 3
            and P.LOCATIONID in('10551')
                --and date_trunc('day',P.BILLDATE)between '2024-04-01' and '2024-04-30'
            and date(P.BILLDATE) between date('2024-01-01') and date('2024-04-30')
            group by
                PBD.BILLNO)TAB4 on TAB1.BILLNO = TAB4.BILLNO
left join
    (select
        PBD.BILLNO,
        SUM(PBD.AMOUNTLIMIT)IP_PACKAGE_DOCTORFEES
    from
        BILLING.PATIENTBILL P,
        BILLING.PACKAGEBILLDETAILS PBD
    where
        PBD.SERVICETYPEID in(6,161)
            and P.BILLNO = PBD.BILLNO
            and P.PATIENTSERVICE = 3
            and P.LOCATIONID in ('10551')
                --and date_trunc('day',P.BILLDATE)between '2024-04-01' and '2024-04-30'
            and date(P.BILLDATE) between date('2024-01-01') and date('2024-04-30')
            group by
                PBD.BILLNO)TAB5 on TAB1.BILLNO = TAB5.BILLNO) TT
                where TT.LOCATIONID in ('10551');