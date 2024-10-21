
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/quotes.dart';
import 'SafeWebView.dart';

class CustomCaroucel extends StatelessWidget {
  const CustomCaroucel({super.key});

  void navigateToRoute(BuildContext context,Widget route){
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>route));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(items: List.generate(imageSliders.length, (index) => Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: (){
              if(index==0){
                navigateToRoute(context, SafeWebView(url: "https://www.goaid.in/women-safety-in-india/",));
              }else if(index==1){
                navigateToRoute(context, SafeWebView(url: "https://www.pwc.com/gx/en/industries/government-public-services/public-sector-research-centre/achieving-safety-security.html",));
              }
              else if(index==2){
                navigateToRoute(context, SafeWebView(url:"https://vikaspedia.in/social-welfare/women-and-child-development/child-development-1/resources-on-safe-childhood-for-panchayat-members/child-protection"));
              }
              else if(index==3){
                navigateToRoute(context, SafeWebView(url:"https://pib.gov.in/Pressreleaseshare.aspx?PRID=1575574"));
              }
          },
          child: Container(
            decoration: BoxDecoration(
          
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  fit:BoxFit.cover,
                  image: NetworkImage(imageSliders[index])),
          
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent
                    ]
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8),
                  child: Text(articleTitle[index],style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width*0.05
                  ),),
                ),
              ),
            ),
          
          ),
        ),
      )), options: CarouselOptions(
        aspectRatio: 2.0,
        autoPlay: true,
        enlargeCenterPage: true
      ),

      ),

    );
  }
}
