with names as (
    select distinct
        customno,
        customname
    from dwh_ods.fusiondb2_shandongruikang_fb_u_recbill
    where dt = date_format(current_timestamp(), "yyyy-MM-dd")
        and customname not in ("曹县中医医院")
), recbill as (
    select
		substring(billdate, 1, 7) as `month`,
		money_de as recbill_money,
		lpad(customno, 10, '0') as `customno`,
		billno as `billno`,
		lpad(itemno, 18, '0') as itemno
	from dwh_ods.fusiondb2_shandongruikang_fb_u_recbill
	where dt = date_format(current_timestamp(), "yyyy-MM-dd")
	    and money_de > 0
	    and customname in (
	        '中国人民解放军联勤保障部队第九七〇医院', '临朐县海浮山医院', '临沂市兰山区人民医院', '临沂市妇幼保健院（山东医学高等专科学院第一附属医院、临沂市妇女儿童医院', '临沂经济技术开发区人民医院', '临清市中医院', '乐陵市人民医院', '兰陵县人民医院', '冠县中医医院', '夏津县中医院', '山东医学高等专科学校附属医院', '山东省血友病诊疗中心', '德州市第二人民医院', '日照市岚山区人民医院', '日照心脏病医院', '日照港口医院', '昌乐中医院', '曲阜市中医院', '泗水县中医医院', '济宁市精神病防治院', '滨州市第二人民医院', '烟台市桃村中心医院', '烟台市芝罘区妇幼保健院', '烟台海港医院', '费县中医医院', '邹城市人民医院', '青岛大学附属心血管病医院', '青岛市中医医院（青岛市海慈医院）', '青岛市即墨区中医医院', '青岛市市南区人民医院', '青岛市第三人民医院', '青岛市第九人民医院', '青岛市胸科医院', '青岛眼科医院', '高唐县中医院', '齐河县人民医院', '莱州市中医医院'
	    )
), recbill_distinct as (
    select
        month,
        sum(recbill_money) as  `recbill_money`,
        customno,
        billno,
        itemno
    from recbill
    group by month, customno, billno, itemno
), verifydetail as (
    select distinct
        substring(busidate, 1, 7) as `month`,
		money_de as verifydetail_money,
		lpad(cuscode, 10, '0') as `customno`,
		billno as `billno`,
		lpad(mtrcode, 18, '0') as itemno
	from dwh_ods.fusiondb2_shandongruikang_fb_u_verifydetail
	where dt = date_format(current_timestamp(), "yyyy-MM-dd")
	    and money_de > 0
	    and cusname in (
	        '中国人民解放军联勤保障部队第九七〇医院', '临朐县海浮山医院', '临沂市兰山区人民医院', '临沂市妇幼保健院（山东医学高等专科学院第一附属医院、临沂市妇女儿童医院', '临沂经济技术开发区人民医院', '临清市中医院', '乐陵市人民医院', '兰陵县人民医院', '冠县中医医院', '夏津县中医院', '山东医学高等专科学校附属医院', '山东省血友病诊疗中心', '德州市第二人民医院', '日照市岚山区人民医院', '日照心脏病医院', '日照港口医院', '昌乐中医院', '曲阜市中医院', '泗水县中医医院', '济宁市精神病防治院', '滨州市第二人民医院', '烟台市桃村中心医院', '烟台市芝罘区妇幼保健院', '烟台海港医院', '费县中医医院', '邹城市人民医院', '青岛大学附属心血管病医院', '青岛市中医医院（青岛市海慈医院）', '青岛市即墨区中医医院', '青岛市市南区人民医院', '青岛市第三人民医院', '青岛市第九人民医院', '青岛市胸科医院', '青岛眼科医院', '高唐县中医院', '齐河县人民医院', '莱州市中医医院'
	    )
), verifydetail_distinct as (
    select
        month,
        sum(verifydetail_money) as `verifydetail_money`,
        customno,
        billno,
        itemno
    from verifydetail
    group by month, customno, billno, itemno
), match as (
    select
        t1.customno,
        t1.billno,
        t1.itemno,
        t1.month as `recbill_month`,
        t1.recbill_money,
        t2.month as `verifydetail_month`,
        t2.verifydetail_money
        
    from recbill_distinct as t1, verifydetail_distinct as t2
    where t1.billno = t2.billno
        and t1.customno = t2.customno
        and t1.itemno = t2.itemno
), recbill_data as (
    select distinct
        customno,
        billno,
        itemno,
        recbill_month,
        recbill_money
    from match
    where recbill_month >= "2019-01"
        and recbill_month <= "2020-06"
), verifydetail_data as (
    select distinct
        customno,
        billno,
        itemno,
        recbill_month,
        verifydetail_month,
        verifydetail_money
    from match
), recbill_group as (
    select
        customno,
        recbill_month,
        sum(recbill_money) as recbill_money_sum
    from recbill_data
    group by customno, recbill_month
), verifydetail_group as (
    select
        customno,
        recbill_month,
        verifydetail_month,
        sum(verifydetail_money) as verifydetail_money_sum
    from verifydetail_data
    group by customno, recbill_month, verifydetail_month
), verifydetail_group_extend as (
    select
        t1.*
    from verifydetail_group as t1, bigdata.shandongruikang_months as t2
    where t1.recbill_month = t2.month_id
        and t1.verifydetail_month >= t2.month_0
        and t1.verifydetail_month <= t2.month_11
        and t2.month_id >= "2019-01"
        and t2.month_id <= "2020-06"
), key_month as (
    select
        month_id,
        month_0 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_1 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_2 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_3 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_4 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_5 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_6 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_7 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_8 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_9 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_10 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_11 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
        select
        month_id,
        month_12 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_13 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_14 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_15 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_16 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_17 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_18 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_19 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_20 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_21 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_22 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
    union all
    select
        month_id,
        month_23 as `v_month`,
        0 as `money`
    from bigdata.shandongruikang_months
), key_customno as (
    select distinct customno
    from recbill
), zero_all as (
    select
        *
    from verifydetail_group_extend
    union all
    select
        customno,
        month_id,
        v_month,
        money
    from key_customno, key_month
    where month_id >= "2019-01"
        and month_id <= "2020-06"
), verifydetail_group_extend_zero as (
    select
        customno,
        recbill_month,
        verifydetail_month,
        sum(verifydetail_money_sum) as `verifydetail_money_sum`
    from zero_all
    group by customno, recbill_month, verifydetail_month
), recbill_result as (
    select 
        t2.customname,
        t1.*
    from recbill_group as t1, names as t2
    where t1.customno = t2.customno
), verifydetail_result as (
    select 
        t2.customname,
        t1.*
    from verifydetail_group_extend_zero as t1, names as t2
    where t1.customno = t2.customno
)
select
    t2.customname,
    t2.customno,
    t2.recbill_month,
    t1.recbill_money_sum,
    t2.verifydetail_month,
    t2.verifydetail_money_sum
from recbill_result as t1, verifydetail_result as t2
where t1.customno = t2.customno
    and t1.recbill_month = t2.recbill_month
order by t2.customno, t2.recbill_month, t2.verifydetail_month
;
