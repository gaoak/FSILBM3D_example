#include"parameters2D.h"
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include<cmath>
#define SEGTYPE 2

using namespace std;

vector<double> Cylinder(double t, double r) {
    vector<double> res(3);
    double theta = 2. * M_PI * t;
    r = 0.5 * r;
    res[0] = r * cos(theta);
    res[1] = r * sin(theta);
    res[2] = 0.;
    return res;
}

vector<double> VerticalLine(double t, double r) {
    vector<double> res(3);
    res[0] = 0.;
    res[1] = r*t;
    res[2] = 0.;
    return res;
}

vector<double> HorizontalLine(double t, double r) {
    vector<double> res(3);
    res[0] = r*t;
    res[1] = 0.;
    res[2] = 0.;
    return res;
}

vector<double> HorizontalCos(double t, const std::vector<double> &r) {
    vector<double> res(3);
    res[0] = t*r[0];
    res[1] = r[1]*cos(t*2.*M_PI);
    res[2] = 0.;
    return res;
}

vector<double> HorizontalSquare(double t, const std::vector<double> &r) {
    vector<double> res(3);
    res[0] = t*r[0];
    res[1] = r[1]*cos(t*2.*M_PI);
    res[2] = 0.;
    return res;
}

vector<double> GeometryShape(double t, const std::vector<double> &r, vector<double> &normal) {
    std::vector<double> p;
    if (GEOMTYPE == 0) {
        p = Cylinder(t, r[0]);
    }
    else if (GEOMTYPE == 1) {
        p = VerticalLine(t, r[0]);
    }
    else if (GEOMTYPE == 2) {
        p = HorizontalLine(t, r[0]);
    }
    else if (GEOMTYPE == 3) {
        p = HorizontalCos(t, r);
    }
    else if (GEOMTYPE == 4) {
        p = HorizontalSquare(t, r);
    }
    else {
        p = std::vector<double>(0);
    }
    p.push_back(normal[0]);
    p.push_back(normal[1]);
    p.push_back(normal[2]);
    return p;
}

void GeneratePoints(int N, const std::vector<double> &r, vector<vector<double> > &points, vector<double> &normal, bool closed) {
    if(!closed) {
        --N;
    }
    points.clear();
    points.push_back(vector<double>());
    double dt = 1./N;
    for(int i=0; i<N; ++i) {
        points.push_back(GeometryShape(dt*i, r, normal));
    }
    if(!closed) {
        points.push_back(GeometryShape(1., r, normal));
    }
}

void GenerateElements(vector<vector<double> > &points, vector<vector<int> > &elements, vector<vector<int> > &boundCondition, bool closed) {
    if(points.size()<3) {
        return;
    }
    elements.clear();
    boundCondition.clear();
    elements.push_back(vector<int>());
    boundCondition.push_back(vector<int>());
    int Ne = (int)points.size() - 2;
    for(int i=1; i<=Ne; ++i) {
        vector<int> p = {i, i, i+1, i+1, SEGTYPE, 1};
        elements.push_back(p);
    }
    if(closed) {
        vector<int> p = {Ne+1, Ne+1, 1, 1, SEGTYPE, 1};
        elements.push_back(p);
    }
    for(int i=1; i<(int)points.size(); ++i) {
        vector<int> p = {i, 0, 0, 0, 0, 0, 0};
        boundCondition.push_back(p);
    }
    boundCondition[1][1] = 1;
}

double SpanConst(double l) {
    double res;
    res = l;
    return res;
}

double SpanLine(double t, const std::vector<double> &l) {
    double res;
    res = l[0]+l[1]*t;
    return res;
}

double SpanEllipse(double t, const std::vector<double> &l) {
    double res;
    res = l[0]+l[3]*sqrt(1.0-pow((t-l[1])/l[2],2));
    return res;
}

double SpanCos(double t, const std::vector<double> &l) {
    double res;
    res = l[0]+l[1]*cos(t*l[2]*2.*M_PI+l[3]*180./M_PI);
    return res;
}

double SpanSawtooth(double t, const std::vector<double> &l) {
    double res, x, slop;
    x    = fmod(t,l[1]);
    slop = 2*l[2]/l[1];
    if(x <= 0.5*l[1]) 
        res  = l[0]+slop*x;
    else
        res  = l[0]+l[2]-slop*(x-0.5*l[1]);
    return res;
}

double SpanShape(double t, int spantp, std::vector<double> &spanpm) {
    if (spantp == 0)
        return SpanConst(spanpm[0]);
    else if (spantp == 1)
        return SpanLine(t, spanpm);
    else if (spantp == 2)
        return SpanEllipse(t, spanpm);
    else if (spantp == 3)
        return SpanCos(t, spanpm);
    else if (spantp == 4)
        return SpanSawtooth(t, spanpm);
    else
        return 0.;
}

void GenerateSpans(int N, const double r, std::vector<int> &spantp, std::vector<std::vector<double> > &spanpm, vector<double> &Lspan, vector<double> &Rspan, vector<int> &Nspan, bool closed) {
    if(!closed) {
        --N;
    }
    Lspan.clear();
    Rspan.clear();
    Nspan.clear();
    Lspan.push_back(0.);
    Rspan.push_back(0.);
    Nspan.push_back(0);
    double dt = 1./N;
    for(int i=0; i<N; ++i) {
        Lspan.push_back(SpanShape(dt*i, spantp[0], spanpm[0]));
        Rspan.push_back(SpanShape(dt*i, spantp[1], spanpm[1]));
    }
    if(!closed) {
        Lspan.push_back(SpanShape(1., spantp[0], spanpm[0]));
        Rspan.push_back(SpanShape(1., spantp[1], spanpm[1]));
    }
    for(int i=1; i<=N; ++i) {
        Nspan.push_back(floor((Lspan[i]+Rspan[i]+Lspan[i+1]+Rspan[i+1])/(2.*dt)));
    }
    if(!closed) {
        Nspan.push_back(1.);
    }
}

void Output(string filename, vector<vector<double> > &points, vector<vector<int> > &ele, vector<vector<int> > &bc, vector<double> &Lspan, vector<double> &Rspan, vector<int> &Nspan) {
    char buff[1000];
    string endtag("END");
    ofstream ofile(filename.c_str());
    ofile << "Frame3D : point number, element number, material number\n";
    sprintf(buff, "%5d %5d %5d\n", int(points.size()) - 1, int(ele.size()) - 1, 1);
    ofile << buff << endtag << "\n"; 
    //output points
    sprintf(buff, "%5d %22s %22s %22s %22s %22s\n", int(points.size())-1, "X", "Y", "Z", "Lspan", "Rspan");
    ofile << buff;
    for(size_t i=1; i<points.size(); ++i) {
        sprintf(buff, "%5d %22.18f %22.18f %22.18f %22.18f %22.18f %22.18f %22.18f %22.18f\n", (int)i, points[i][0], points[i][1], points[i][2], Lspan[i], Rspan[i], points[i][3], points[i][4], points[i][5]);
        ofile << buff;
    }
    ofile << endtag << "\n";
    // output elements
    sprintf(buff, "%5d %5s %5s %5s %5s %5s\n", int(ele.size()) - 1, "I", "J", "K", "TYPE", "MAT", "Nspan");
    ofile << buff;
    for(size_t i=1; i<ele.size(); ++i) {
        sprintf(buff, "%5d %5d %5d %5d %5d %5d %5d\n", ele[i][0], ele[i][1], ele[i][2], ele[i][3], ele[i][4], ele[i][5], Nspan[i]);
        ofile << buff;
    }
    ofile << endtag << "\n";
    // output boundary conditions
    sprintf(buff, "%5d %5s %5s %5s %5s %5s %5s\n", int(points.size()) - 1, "XTRA", "YTRA", "ZTRA", "XROT", "YROT", "ZROT");
    ofile << buff;
    for(size_t i=1; i<points.size(); ++i) {
        sprintf(buff, "%5d %5d %5d %5d %5d %5d %5d\n", bc[i][0], bc[i][1], bc[i][2], bc[i][3], bc[i][4], bc[i][5], bc[i][6]);
        ofile << buff;
    }
    ofile << endtag << "\n";
    // output property parameters
    ofile << "1   E           G           A           RHO         GAMMA       IP          IA          IB" << "\n";
    ofile << "1   0.100D+01   0.100D+01   0.100D+01   0.100D+01   0.000D+00   0.100D+01   0.150D+01   0.500D+00" << "\n";
    ofile << endtag << endl;
    ofile.close();
}

int main() {
    std::vector<double> param = filaparams;
    int Np = NPOINTS;
    string filename("plate.dat");
    vector<vector<double> > points;
    vector<vector<int> > elements;
    vector<vector<int> > boundCondition;
    std::vector<int> spantp = spantype;
    std::vector<std::vector<double> > spanpm = spanparams;
    vector<double> Lspan;
    vector<double> Rspan;
    vector<int> Nspan;
    GeneratePoints(Np, param, points, normal, CLOSED);
    GenerateElements(points, elements, boundCondition, CLOSED);
    GenerateSpans(Np, param[0], spantp, spanpm, Lspan, Rspan, Nspan, CLOSED);
    Output(filename, points, elements, boundCondition, Lspan, Rspan, Nspan);
    
    return 0;
}
