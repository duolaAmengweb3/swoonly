# Swoonly — 定位与发行/ASO 策略

> 2026-06-04 · 解决一个问题:**那么多小说 app,我们怎么被搜到/被看到。**
> 关联:`产品需求.md §九`、`上架文案.md`、记忆 `project_distribution_bottleneck`、`project_pmtool_5.0_self_distribution`。

## 〇、残酷前提
- "romance novels / read books" 这类**头部词被巨头焊死**(GoodNovel/Dreame/Webnovel 几十万评)。新 app 正面抢 = 零希望——这正是我们 15 个 app 沉默的老病。
- 所以**不抢头部**,走下面三条路叠加。**ASO 单独啃不下巨头垄断的品类,别赌搜索自然量救场。**

## 一、定位:不做"又一个小说 app",做"**没有币的那个**"
一句话身份:**Unlimited romance. No coins. No ads.**
- 不只是卖点,是**差异化身份**——整个品类被骂的就是币。把"反币"做成品牌,用户记得住("那个不要币的"),且天然可晒(见 §三)。
- 命名/副标题/截图首图/TikTok 脚本——**全部收敛到这一句**。

## 二、ASO:放弃头部,吃两类低竞争高意图词

**字段分工(关键:三处不重复,扩大覆盖面)**
- **标题**`Romance Stories: Swoonly` → 占 romance / stories。
- **副标题**`Werewolf, billionaire, fantasy` → 占三个最大体裁词。
- **关键词字段**(≤100,**不重复**标题/副标题里的词)→ 见下。

**关键词字段(Sonar 实测后,≤100,Apple 会自动和标题/副标题词组合):**
```
unlimited,reading,coins,ads,enemies,lovers,vampire,fae,alpha,reborn,booktok,ceo,mate,rejected
```

**Sonar 实测 pop/diff(2026-06-04,store=ios/us)——纠正了拍脑袋:**
| 词 | pop | diff | 取舍 |
|---|--:|--:|---|
| booktok | 46 | 60 | 最大词,硬但占(读者自我标签) |
| romance novels / free romance novels | 25 | 74 | 头部,弃 |
| enemies to lovers | 22 | 71 | 有量,占(单词组合) |
| read romance | 21 | 66 | 占 |
| second chance / fae romance | 19/17 | 69/61 | 占(reborn/fae) |
| **unlimited reading** | 15 | **55** | ⭐ pop中+diff相对低+楔子词,重点占 |
| alpha / vampire romance | 12/10 | 57/56 | 占 |
| no coins / "no ads no coins" | 12/22 | 57/71 | 楔子,占 coins/ads |
| werewolf romance | 7 | 45 | pop 太低(量在 app 名);副标题已占 werewolf |
| fated mates / rejected mate | 5/5 | 39/**16** | pop≈0,只留 rejected/mate 兜底超低 diff |

**结论(数据实锤):整个品类 diff 全在 55–79,没有"低diff+有量"的词。** 所以:
- 关键词只能**边际优化**(选 pop/diff 平衡最好的,别浪费字符在 74 的头部词)。
- **真正的量不在搜索 → 看 §三 BookTok + §四 ASA。** 这条数据再次证明 ASO 单独啃不下本品类。

## 三、真正的量在 BookTok,不在搜索框
言情读者**发现书的地方是 TikTok/小红书/Reels**。我们的定位天生可晒:
> "我以前读完一本书要花 $200 的币…直到我找到一个一个价无限读的 app" —— **愤怒 + 爽**的叙事,正是 BookTok 会传的(回到 5.0 自传播逻辑)。

**TikTok/Reels 脚本方向(3 类):**
1. **愤怒对比**:截图币 app 一本书的总价 vs 我们 $5.99 无限。
2. **体裁钩子**:"POV: you just found an app with unlimited werewolf romance, no coins" + 翻封面。
3. **书摘卡**:某章高甜/高虐片段截图 + "read the rest free on Swoonly"。

## 四、少量 Apple Search Ads 点火(便宜、精准)
投三类词:① 体裁词(werewolf romance / fated mates)② **反币词**(no coins reading / unlimited romance)③ **竞品品牌词**(novelbar / dreame / galatea alternative)。配 **Custom Product Pages**:不同体裁广告进不同截图落地页(狼人受众看狼人封面)。

## 五、落地清单(全部收敛到"没有币·无限读")
- [ ] 关键词字段换成 §二 的优化版(已同步 `marketing/asc_metadata.json` + `上架文案.md`)。
- [ ] 截图首图大字 = "Unlimited. No coins. No ads."(已做)。
- [ ] 描述首句 = 同一句(已做)。
- [ ] 准备 3 条 BookTok 脚本(上线即发)。
- [ ] ASA:体裁 + 反币 + 竞品词,小预算点火。
- [ ] CPP:按体裁建 2–3 个落地页。

## 六、诚实结论
我们能赢的路径 = **长尾体裁词 + 反币叛逃者词(ASO 打底)+ BookTok 愤怒叙事(自传播拉量)+ 少量 ASA(点火)**,三条叠加。**不是赌 App Store 搜索。** 从命名到截图到 TikTok 脚本,都说同一句:**没有币 · 无限读。**
