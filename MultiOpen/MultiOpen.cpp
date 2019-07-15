#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

int main()
{
	std::ifstream stream("config.ini");
	if (!stream.is_open())
	{
		return 0;
	}
	std::string from;
	std::string to;
	stream >> from;
	stream >> to;
	stream.close();

	std::ifstream foldersStream("folders.ini");
	if (!foldersStream.is_open())
	{
		return 0;
	}
	std::vector<std::string> folders;
	std::string s;
	while (foldersStream >> s)
	{
		folders.push_back(s);
	}
	foldersStream.close();

	for (size_t i = 0; i < folders.size(); ++i)
	{
		std::stringstream ss;
		ss << "mklink /D " << to << "\\" << folders[i] << " " << from << "\\" << folders[i];
		//std::cout << ss.str() << std::endl;
		system(ss.str().c_str());
	}

	system("PAUSE");
	return 1;
}