@ComponentV2
export struct Pagination {
  @Param @Once currentPage: number = 1
  @Param @Once totalPages: number = 10

  @Param
  onCurrentPageChange:(currentPage:number)=>void = ()=>{}

  @Monitor('currentPage')
  pageChange(){
    this.onCurrentPageChange(this.currentPage)
  }

  build() {
    Row() {
      Button("上一页")
        .opacity(this.currentPage <= 1 ? 0.4 : 1) // 第一页时变灰
        .onClick(() => {
          if (this.currentPage > 1) this.currentPage--
        })
        .border({
          radius:5,
          width:2,
          color:Color.Blue
        })

      Text(`第 ${this.currentPage} 页 / 共 ${this.totalPages} 页`)

      Button("下一页")
        .opacity(this.currentPage >= this.totalPages ? 0.4 : 1) // 末页时变灰
        .onClick(() => {
          if (this.currentPage < this.totalPages) this.currentPage++
        })
        .border({
          radius:5,
          width:2,
          color:Color.White
        })
    }
    .justifyContent(FlexAlign.SpaceAround) // 均匀分布
    .width("100%")
  }
}