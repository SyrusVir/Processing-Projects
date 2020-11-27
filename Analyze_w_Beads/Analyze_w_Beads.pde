import beads.*;

AudioContext ac;
PowerSpectrum ps;

void setup() {
  size (1024, 512);
  ac = new AudioContext();
  int[] s = new int[2];
  s[0] = 0;
  UGen streamIn = ac.getAudioInput();
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(streamIn);
  
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(g);
  
  FFT fft = new FFT();
  sfs.addListener(fft);
  ps = new PowerSpectrum();
  fft.addListener(ps);
  ac.out.addDependent(sfs);
  ac.start();
}

void draw() {
  float[] features = ps.getFeatures();
  print(features);
}