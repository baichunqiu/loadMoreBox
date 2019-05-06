# loadmore说明

封装loadmoreBox 和pullrefreshBox 
原因：网上的load more 封装widget 几乎都有一个bug：加载第一页数据比较少的时（最后一个item以显示出来）自动触发加载 逻辑。
注意：1.通过animalbuild 构建的load 和refresh 视图
      2.设置physics属性：在条目比较少不足满屏时，刷新、加载将被禁止 条目较多满屏时不影响 扔可以 刷新和加载 。
 # 具体使用
  PullRefreshBox(
        onRefresh: () async => Future.delayed(Duration(seconds: 2)),
        child: LoadMoreBox(
          onLoad: () async => Future.delayed(Duration(seconds: 2)),
          child: ListView.separated(
            /// 设置physics属性
            /// 在条目比较少不足满屏时，刷新、加载将被禁止 条目较多满屏时不影响 扔可以 刷新和加载 。
//            physics: ClampingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (ctx, index) => ListTile(
                  title: Text("$index"),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
            separatorBuilder: (ctx, index) => Divider(
                  color: Colors.green,
                  height: 0.5,
                ),
          ),
        ),
      )

