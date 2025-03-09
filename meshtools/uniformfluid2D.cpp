#include"parameters2D.h"

#include<iostream>
#include<fstream>
#include<string>

using namespace std;

char buff[1000];

void outputline(ofstream &file, double xmin, double xmax, int Nx, char X) {
    sprintf(buff, "%05d         %c\n", Nx, X);
    file << buff;
    double dx = (xmax - xmin)/(Nx - 1.);
    for(int i=0; i<Nx; ++i) {
        sprintf(buff, "%05d   %25.17e\n", i+1, xmin + dx * i);
        file << buff;
    }
}

int main(int argc, char *argv[]) {
    int Nx = NX;
    int Ny = NY;
    double xmin = XMIN;
    double xmax = XMAX;
    double ymin = YMIN;
    double ymax = YMAX;
    string filename("FluidMesh.dat");
    ofstream outfile(filename.c_str());
    outputline(outfile, xmin, xmax, Nx, 'X');
    outputline(outfile, ymin, ymax, Ny, 'Y');
    outfile.close();
}
