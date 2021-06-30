# windows+python3环境

> **Step 1: hue端**  
```
(1) 在hue平台上运行zhangqi.sql（zhangqi.sql文件在本文件夹内，复制进hue执行，代码中医院列表(两次出现)可编辑修改）
(2) 将hue平台上运行结果以"Excel"格式下载至文件夹input内，假设命名为test.xlsx
```

> **Step 2: 本地Python**  
```
(1) 进入项目所在目录Ruikang_Zhangqi
> cd xxxxxxxx\Ruikang_Zhangqi
(2) 安装依赖
xxxxxxxx\Ruikang_Zhangqi> pip install -r requirements.txt
(3) 执行统计处理脚本，这里的test.xlsx即方才下载的文件名
xxxxxxxx\Ruikang_Zhangqi> python account_period.py test.xlsx
(4) 结果将出现在文件夹output中
```