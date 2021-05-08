//Swimmer class to hold information about individual swimmers
class Swimmer{
  String _name;
}

//List to hold the images of the swimmers from the graphics folder
List<String> strImg = ['graphics/male_six.jpg', 'graphics/female_two.jpg',
  'graphics/male_four.jpg', 'graphics/female_one.jpg',
  'graphics/male_three.jpg','graphics/female_three.jpg'];

//Method to get images from the strImg list at a specified position
String getImage(int position){
  return strImg[position];
}