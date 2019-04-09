package kabam.rotmg.news.model {
public class DefaultNewsCellVO extends NewsCellVO {

    public function DefaultNewsCellVO(_arg_1:int) {
        imageURL = "";
        linkDetail = "https://github.com/NotLegend/VoidClient/blob/master/README.md";
        headline = (((_arg_1 == 0)) ? "Hacked Client Wiki" : "HC Wiki");
        startDate = (new Date().getTime() - 0x3B9ACA00);
        endDate = (new Date().getTime() + 0x3B9ACA00);
        networks = ["kabam.com", "kongregate", "steam", "rotmg"];
        linkType = NewsCellLinkType.OPENS_LINK;
        priority = 999999;
        slot = _arg_1;
    }

}
}//package kabam.rotmg.news.model
