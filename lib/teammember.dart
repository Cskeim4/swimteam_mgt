class Swimmer{
  String _name;
}

List<String> strImg = ['graphics/male_six.jpg', 'graphics/female_two.jpg',
  'graphics/male_four.jpg', 'graphics/female_one.jpg',
  'graphics/male_three.jpg','graphics/female_three.jpg'];

String getImage(int position){
  return strImg[position];
}