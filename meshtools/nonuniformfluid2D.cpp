#include<vector>
#include<iostream>
#include<fstream>
#include<string>
#include"parameters2D.h"
using namespace std;

char buff[1000];

void outputline(ofstream &file, std::vector<double> &x, std::vector<int> N, char X) {
    int Nx = 1;
    for(size_t s=0; s<N.size(); ++s) {
        Nx += N[s];
    }
    sprintf(buff, "%05d         %c\n", Nx, X);
    file << buff;
    int count = 1;
    for(size_t s=0; s<N.size(); ++s) {
        double dx = (x[s+1] - x[s])/N[s];
        for(int i=0; i<N[s]; ++i) {
            sprintf(buff, "%05d   %25.17e\n", count, x[s] + dx * i);
            file << buff;
            ++count;
        }
    }
    sprintf(buff, "%05d   %25.17e\n", count, x[N.size()]);
    file << buff;
}

int main(int argc, char *argv[]) {
    string filename("FluidMesh.dat");
    ofstream outfile(filename.c_str());
    outputline(outfile, xFMesh, NxFMesh, 'X');
    outputline(outfile, yFMesh, NyFMesh, 'Y');
    outfile.close();
}
