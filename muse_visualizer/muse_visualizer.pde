/**
* Muse Visualizer
*
* @author aa_debdeb
* @date 2015/12/21
*
* Before running this program,you need to launch 
* MuseIO by below command in your terminal.
* 
* $ muse-io --device Muse-XXXX --osc osc.udp://localhost:5000
*
*/

import oscP5.*;

OscP5 oscP5;
color bgColor = color(32);
color baseColor = color(128);
color[] chColor = {color(0, 139,  139), color(50, 205, 50), color(255, 140, 0), color(199, 21, 133)};


ArrayList<Float>[] rawEEG;
float[] accelerometer;
float[][] rawFFT;
float[] lowFreqAbs;
float[] deltaAbs;
float[] thetaAbs;
float[] alphaAbs;
float[] betaAbs;
float[] gammaAbs;

int blink;
int jawClench;

float concentration;
float mellow;

void setup(){
  size(800, 600);
  smooth();
  frameRate(60);
  textSize(10);
  textAlign(CENTER);
  
  oscP5 = new OscP5(this, 5000);
  
  rawEEG = new ArrayList[4];
  for(int i = 0; i < 4; i++){
    rawEEG[i] = new ArrayList<Float>();
    for(int j = 0; j < 300; j++){
      rawEEG[i].add(1600.0);
    }
  }
  accelerometer = new float[3];
  rawFFT = new float[4][129];
  lowFreqAbs = new float[4];
  deltaAbs = new float[4];
  thetaAbs = new float[4];
  alphaAbs = new float[4];
  betaAbs = new float[4];
  gammaAbs = new float[4];
  blink = 0;
  jawClench = 0;
  concentration = 0.0;
  mellow = 0.0;
}

void draw(){

  background(bgColor);
  noFill();
  stroke(chColor[0]);
  drawRawEEG(rawEEG[0], 25, 25, 362.5, 50);
  stroke(chColor[1]);
  drawRawEEG(rawEEG[1], 412.5, 25, 362.5, 50);
  stroke(chColor[2]);
  drawRawEEG(rawEEG[2], 25, 175, 362.5, 50);
  stroke(chColor[3]);
  drawRawEEG(rawEEG[3], 412.5, 175, 362.5, 50);
  
  noStroke();
  fill(chColor[0]);
  drawRawFFT(rawFFT[0], 25, 100, 362.5, 50);
  fill(chColor[1]);
  drawRawFFT(rawFFT[1], 412.5, 100, 362.5, 50);
  fill(chColor[2]);
  drawRawFFT(rawFFT[2], 25, 250, 362.5, 50);
  fill(chColor[3]);
  drawRawFFT(rawFFT[3], 412.5, 250, 362.5, 50);
  
  drawAbsBandPower(lowFreqAbs, 25, 350, 115, 100);
  drawAbsBandPower(deltaAbs, 152, 350, 115, 100);
  drawAbsBandPower(thetaAbs, 279, 350, 115, 100);
  drawAbsBandPower(alphaAbs, 406, 350, 115, 100);
  drawAbsBandPower(betaAbs, 533, 350, 115, 100);
  drawAbsBandPower(gammaAbs, 660, 350, 115, 100);
  fill(baseColor);
  text("low freqs(1~8Hz)", 25, 340, 115, 100);
  text("delta(1~4Hz)", 152, 340, 115, 100);
  text("theta(5~8Hz)", 279, 340, 115, 100);
  text("alpha(9~13Hz)", 406, 340, 115, 100);
  text("beta(12~30Hz)", 533, 340, 115, 100);
  text("gamma(30~50Hz)", 660, 340, 115, 100);

  fill(baseColor);
  text("blink", 0, 470, 200, 100);
  text("jaw clench", 200, 470, 200, 100);
  text("concentration", 400, 470, 200, 100);
  text("mellow", 600, 470, 200, 100);
  drawMuscleMovement(blink, 100, 530, 50);
  drawMuscleMovement(jawClench, 300, 530, 50);
  drawExperimental(concentration, 500, 530, 50);
  drawExperimental(mellow, 700, 530, 50);
}

void drawRawEEG(ArrayList<Float> data, float x, float y, float w, float h){
  pushMatrix();
  translate(x, y);
  beginShape();
  for(int i = 0; i < data.size(); i++){
    vertex(map(i, 0, data.size(), 0, w), map(data.get(i), 0, 1682.815, h, 0));
  }
  endShape();
  popMatrix();
}

void drawRawFFT(float[] data, float x, float y, float w, float h){
  pushMatrix();
  translate(x, y);
  float binW = w / data.length;
  for(int i = 0; i < data.length; i++){
    float binH = map(data[i], -40.0, 20.0, 0, h);
    rect(i * binW, h - binH, binW, binH);
  }
  popMatrix();
}

void drawAbsBandPower(float[] data, float x, float y, float w, float h){
  pushMatrix();
  translate(x, y);
  float binW = w / data.length;
  for(int i = 0; i < data.length; i++){
    fill(chColor[i]);
    float binH = map(data[i], -2.5, 2.5, 0, h);
    rect(i * binW, h - binH, binW, binH);
  }
  popMatrix();
}

void drawMuscleMovement(int data, float x, float y, float radious){
  float diameter = data == 1 ? radious * 2 * 0.8 : radious * 2 * 0.2;
  ellipse(x, y, diameter, diameter);  
}

void drawExperimental(float data, float x, float y, float radious){
  float diameter = radious * 2 * data;
  ellipse(x, y, diameter, diameter);  
}

void oscEvent(OscMessage msg){
  
  if(msg.checkAddrPattern("/muse/eeg")){
    for(int i = 0; i < 4; i++){
      rawEEG[i].remove(0);
      rawEEG[i].add(msg.get(i).floatValue());
    }
  }
  
  if(msg.checkAddrPattern("/muse/elements/raw_fft0")){
    for(int j = 0; j < 129; j++){
      rawFFT[0][j] = msg.get(j).floatValue();
    }
  }
  if(msg.checkAddrPattern("/muse/elements/raw_fft1")){
    for(int j = 0; j < 129; j++){
      rawFFT[1][j] = msg.get(j).floatValue();
    }
  }
  if(msg.checkAddrPattern("/muse/elements/raw_fft2")){
    for(int j = 0; j < 129; j++){
      rawFFT[2][j] = msg.get(j).floatValue();
    }
  }
  if(msg.checkAddrPattern("/muse/elements/raw_fft3")){
    for(int j = 0; j < 129; j++){
      rawFFT[3][j] = msg.get(j).floatValue();
    }
  }
  
  if(msg.checkAddrPattern("/muse/elements/low_freqs_absolute")){
    for(int i = 0; i < 4; i++){
      lowFreqAbs[i] = msg.get(i).floatValue();
    }
  }  
  if(msg.checkAddrPattern("/muse/elements/low_freqs_absolute")){
    for(int i = 0; i < 4; i++){
      lowFreqAbs[i] = msg.get(i).floatValue();
    }
  }  
  if(msg.checkAddrPattern("/muse/elements/delta_absolute")){
    for(int i = 0; i < 4; i++){
      deltaAbs[i] = msg.get(i).floatValue();
    }
  }  
  if(msg.checkAddrPattern("/muse/elements/theta_absolute")){
    for(int i = 0; i < 4; i++){
      thetaAbs[i] = msg.get(i).floatValue();
    }
  }  
  if(msg.checkAddrPattern("/muse/elements/alpha_absolute")){
    for(int i = 0; i < 4; i++){
      alphaAbs[i] = msg.get(i).floatValue();
    }
  }    
  if(msg.checkAddrPattern("/muse/elements/beta_absolute")){
    for(int i = 0; i < 4; i++){
      betaAbs[i] = msg.get(i).floatValue();
    }
  }    
  if(msg.checkAddrPattern("/muse/elements/gamma_absolute")){
    for(int i = 0; i < 4; i++){
      gammaAbs[i] = msg.get(i).floatValue();
    }
  }    
  
  if(msg.checkAddrPattern("/muse/elements/blink")){
    blink = msg.get(0).intValue();
  }    
  if(msg.checkAddrPattern("/muse/elements/jaw_clench")){
    jawClench = msg.get(0).intValue();
  }
 
  if(msg.checkAddrPattern("/muse/elements/experimental/concentration")){
    concentration = msg.get(0).floatValue();
  }    
  if(msg.checkAddrPattern("/muse/elements/experimental/mellow")){
    mellow = msg.get(0).floatValue();
  } 
}
