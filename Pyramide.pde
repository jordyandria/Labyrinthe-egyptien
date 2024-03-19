int LAB_SIZE = 21;
char labyrinthe [][];
char sides [][][];
int iposX = 1;
int iposY = 0;

int posX = iposX;
int posY = iposY;

int dirX = 0;
int dirY = 1;
int odirX = 0;
int odirY = 1;
int newdirX, newdirY;
int WALLD = 1;

int anim = 0;
boolean animT = false;
boolean animR = false;
boolean animB = false;

boolean inLab = true;

PShape laby0;
PShape ceiling0;
PShape ceiling1;
PShape ground;
PShape pyramid;
PShape sky;

PShape momie,corps,brasDroit,brasGauche, tete,oeil, pupille;

int gridSize = 50; // taille de la grille
int gridHeight = 50; // hauteur maximale de la grille
float noiseScale = 0.1; // facteur d'échelle du bruit

PImage  texture0;
PImage  sable;
PImage  ciel;


void setup() { 
  randomSeed(2);
  size(1000, 1000, P3D);
  texture0 = loadImage("stones.jpg");
  sable = loadImage("texture-sand-71614166835.jpg");
  ciel = loadImage("ciel.jpg");
  labyrinthe = new char[LAB_SIZE][LAB_SIZE];
  sides = new char[LAB_SIZE][LAB_SIZE][4];
  int todig = 0;
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      sides[j][i][0] = 0;
      sides[j][i][1] = 0;
      sides[j][i][2] = 0;
      sides[j][i][3] = 0;
      if (j%2==1 && i%2==1) {
        labyrinthe[j][i] = '.';
        todig ++;
      } else
        labyrinthe[j][i] = '#';
    }
  }
  int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<LAB_SIZE-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<LAB_SIZE-2) gy += 2; // .. va en bas

    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }

  labyrinthe[0][1]                   = ' '; // entree
  labyrinthe[LAB_SIZE-2][LAB_SIZE-1] = ' '; // sortie

  for (int j=1; j<LAB_SIZE-1; j++) {
    for (int i=1; i<LAB_SIZE-1; i++) {
      if (labyrinthe[j][i]==' ') {
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]==' ' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j-1][i][0] = 1;// c'est un bout de couloir vers le haut 
        if (labyrinthe[j-1][i]==' ' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j+1][i][3] = 1;// c'est un bout de couloir vers le bas 
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]==' ' && labyrinthe[j][i+1]=='#')
          sides[j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]==' ')
          sides[j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }

  // un affichage texte pour vous aider a visualiser le labyrinthe en 2D
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      print(labyrinthe[j][i]);
    }
    println("");
  }
  
  //float cubeSize = width/LAB_SIZE;
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;
  
  ceiling0 = createShape();
  ceiling1 = createShape();
  
  ceiling1.beginShape(QUADS);
  ceiling0.beginShape(QUADS);
  
  laby0 = createShape();
  laby0.beginShape(QUADS);
  laby0.texture(texture0);
  laby0.noStroke();
  
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      if (labyrinthe[j][i]=='#') {
        
        laby0.tint(i*25, j*25, 255-i*10+j*10);
        if (j==0 || labyrinthe[j-1][i]==' ') {
          laby0.normal(0, -1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              //float d1 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
              //if (k==0)  d1=0;
              //if (l==-WALLD) d1=-2*abs(d1);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
              
              //float d2 =15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
              //if (k+1==WALLD ) d2=0;
              //if (l==-WALLD) d2=-2*abs(d2);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
              
              //float d3 = 15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
              //if (k+1==WALLD ||l+1==WALLD) d3=0;
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              
              //float d4 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
              //if (k==0 ||l+1==WALLD) d4=0;
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
        }

        if (j==LAB_SIZE-1 || labyrinthe[j+1][i]==' ') {
          laby0.normal(0, 1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
        }

        if (i==0 || labyrinthe[j][i-1]==' ') {
          laby0.normal(-1, 0, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
        }

        if (i==LAB_SIZE-1 || labyrinthe[j][i+1]==' ') {
          laby0.normal(1, 0, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
        }
        ceiling1.fill(32, 255, 0);
        ceiling1.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50);
        ceiling1.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50);
        ceiling1.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50);
        ceiling1.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50);        
      } else {
        laby0.tint(200); // ground
        laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 0);
        laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 0, 1);
        laby0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
        laby0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 1, 0);
        
        ceiling0.fill(32); // top of walls
        ceiling0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50);
        ceiling0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50);
        ceiling0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50);
        ceiling0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50);
      }
    }
  }
  
  laby0.endShape();
  ceiling0.endShape();
  ceiling1.endShape();
  
  ground = createShape();
  ground.beginShape(QUADS);
  ground.texture(sable);
  ground.textureMode(NORMAL);
  ground.noStroke();
    for (int x = -3000; x <= 3000; x += 12) {
      for (int y = -3000; y <= 3000; y += 12) {
        ground.vertex(x, y, (noise(x/10.0, y/10.0) * 20) - wallH, x/sable.width, y/sable.height);
        ground.vertex(x + 50, y, noise((x+50)/10.0, y/10.0) * 20 - wallH, (x+1)/sable.width, y/sable.height);
        ground.vertex(x + 50, y + 50, noise((x+50)/10.0, (y+50)/10.0) * 20 - wallH, (x+1)/sable.width, (y+1)/sable.height);
        ground.vertex(x, y + 50, noise(x/10.0, (y+50)/10.0) * 20 - wallH, x/sable.width, (y+1)/sable.height);
        ground.tint(255, 190, 0);
           
      }
    }
  ground.endShape();
  noStroke();

  sky = createShape(SPHERE, 10000); // Créer une sphère
  PImage skyTexture = loadImage("ciel.jpg"); // Charger la texture de ciel
  sky.setTexture(skyTexture); // Appliquer la texture à la sphère
  
  float pyramidHeight = 70*LAB_SIZE + 100;
  float pyramidWidth = 70*LAB_SIZE + 100;
  float pyramidDepth = 900;
  pyramid = createShape();
  pyramid.beginShape(TRIANGLES);
  //pyramid.textureMode(NORMAL);
  pyramid.texture(texture0);
  
  pyramid.tint(240, 190, 0);
  
  pyramid.vertex(-pyramidWidth/2, pyramidHeight/2, 0, pyramidWidth/texture0.width, pyramidDepth/texture0.height);
  pyramid.vertex(0, 0, pyramidDepth, pyramidWidth/texture0.width, texture0.height);
  pyramid.vertex(pyramidWidth/2, pyramidHeight/2, 0, texture0.width, pyramidDepth/texture0.height);
  
  pyramid.vertex(pyramidWidth/2, pyramidHeight/2, 0, pyramidWidth/texture0.width, pyramidDepth/texture0.height);
  pyramid.vertex(0, 0, pyramidDepth, pyramidWidth/texture0.width, texture0.height);
  pyramid.vertex(pyramidWidth/2, -pyramidHeight/2, 0, texture0.width, pyramidDepth/texture0.height);
  
  pyramid.vertex(pyramidWidth/2, -pyramidHeight/2, 0, pyramidWidth/texture0.width, pyramidDepth/texture0.height);
  pyramid.vertex(0, 0, pyramidDepth, pyramidWidth/texture0.width, texture0.height);
  pyramid.vertex(-pyramidWidth/2, -pyramidHeight/2, 0, texture0.width, pyramidDepth/texture0.height);
  
  pyramid.vertex(-pyramidWidth/2, -pyramidHeight/2, 0, pyramidWidth/texture0.width, pyramidDepth/texture0.height);
  pyramid.vertex(0, 0, pyramidDepth, pyramidWidth/texture0.width, texture0.height);
  pyramid.vertex(-pyramidWidth/2, pyramidHeight/2, 0, texture0.width, pyramidDepth/texture0.height);
  
  pyramid.endShape();
  
  momie = createShape(GROUP);
  //creation du corps 
  corps = createShape();
  corps.beginShape(QUAD_STRIP);
  corps.noStroke();
  for(int i = 1 ; i <= 64 ; i++){
    for(int j = -5; j <= 5 ; j++){
      float a = j/5.*PI;
      float b = (j+1)/5.*PI;
      float r = 8+cos((i-32)*PI/32.);
      corps.fill(127+127*noise(i+j), 63+191*noise(i+j), 31+223*noise(i+j));
      corps.vertex(r*cos(a), r*sin(a), i);
      r = 8+cos((i-31)*PI/64.0);
      corps.vertex(r*cos(b), r*sin(b), (i+1));
    }
  }
  corps.endShape();
  momie.addChild(corps);
  //Ensuite on peut passer a la creation des bras.
  brasDroit = createShape();
  brasDroit.beginShape(QUAD_STRIP);
  brasDroit.noStroke();
  for(int i = 1 ;i <= 84/3; i++){
    for(int j = -5 ; j <= 5 ; j++){
      float a = j/9.*PI;
      float b = (j+1)/9.*PI;
      float r = 4+cos((32)*PI/32.0);
      brasDroit.fill(127+127*noise(i+j), 63+191*noise(i+j), 31+223*noise(i+j));
      brasDroit.vertex(-5+r*sin(a), 2+i, 55+r*cos(a));
      brasDroit.vertex(-5+r*sin(b), 2+(i+1),55+r*cos(b));
    }
  }
  brasDroit.endShape();
  momie.addChild(brasDroit);
  //On passe au bras gauche.
  brasGauche = createShape();
  brasGauche.beginShape(QUAD_STRIP);
  brasGauche.noStroke();
  for(int i = 1 ;i <= 84/3; i++){
    for(int j = -5 ; j <= 5 ; j++){
      float a = j/9.*PI;
      float b = (j+1)/9.*PI;
      float r = 4+cos((32)*PI/32.0);
      brasGauche.fill(127+127*noise(i+j), 63+191*noise(i+j), 31+223*noise(i+j));
      brasGauche.vertex(5+r*sin(a), 2+i, 55+r*cos(a));
      brasGauche.vertex(5+r*sin(b), 2+(i+1),55+r*cos(b));
    }
  }
  brasGauche.endShape();
  momie.addChild(brasGauche);
  //On passe a la tete.
  tete = createShape();
  tete.beginShape(QUAD_STRIP);
  tete.noStroke();
  for(int i = 64; i<= 84; i++){
    for(int j = -5; j <= 5 ; j++){
      float a = j/5.*PI;
      float b = (j+1)/5.0*PI;
      float r = 10+2*cos((i-54)*PI/10.0);
      tete.fill(127+127*noise(i+j), 63+191*noise(i+j), 31+223*noise(i+j));
      tete.vertex(r*cos(a), r*sin(a), i);
      tete.vertex(r*cos(b), r*sin(b), (i+1));
    }
  }
  tete.endShape();
  momie.addChild(tete);
  //Il ne manque plus que les yeux.
  oeil = createShape(SPHERE, 5);
  oeil.setStroke(color(255));
  oeil.translate(0, 10+2*cos((80-54)*PI/10.0), 75);
  momie.addChild(oeil);
  pupille = createShape(SPHERE, 3);
  pupille.setStroke(color(0));
  pupille.translate(0, 10+2*cos((80-54)*PI/10.0)+2, 75.5);
  momie.addChild(pupille);
}

void draw() {
  background(200);
  float cubeSize = width/LAB_SIZE; // taille des cubes
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;
  
  translate(width/2, height/2, -500);
  shape(sky);
  
  if (anim>0) 
    anim--;
  
  if (inLab){
    perspective();
    camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
    noLights();
    stroke(0);
    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i++) {
        if (labyrinthe[j][i]=='#') {
          fill(i*25, j*25, 255-i*10+j*10);
          pushMatrix();
          translate(50+i*cubeSize/8, 50+j*cubeSize/8, 50);
          box(cubeSize/10, cubeSize/10, 5);
          popMatrix();
        }
      }
    }
    pushMatrix();
    fill(0, 255, 0);
    noStroke();
    translate(50+posX*cubeSize/8, 50+posY*cubeSize/8, 50);
    sphere(3);
    popMatrix();
    
    perspective(PI/3, float(width)/float(height), 1, 1000);
    if (animT){
        camera((posX-dirX*anim/20.0)*cubeSize,      (posY-dirY*anim/20.0)*cubeSize,      -cubeSize/6+2*sin(anim*PI/5.0), 
               (posX-dirX*anim/20.0+dirX)*cubeSize, (posY-dirY*anim/20.0+dirY)*cubeSize, -cubeSize/6+4*sin(anim*PI/5.0),
               0, 0, -1);
      }else if (animB){
          camera((posX+dirX*anim/20.0)*cubeSize,      (posY+dirY*anim/20.0)*cubeSize,      -cubeSize/6-2*sin(anim*PI/5.0), 
                 (posX+dirX*anim/20.0+dirX)*cubeSize, (posY+dirY*anim/20.0+dirY)*cubeSize, -cubeSize/6-4*sin(anim*PI/5.0),
                 0, 0, -1);
      }else if (animR){
          camera(posX*cubeSize, posY*cubeSize, -cubeSize/6, 
                (posX+(odirX*anim+dirX*(20-anim))/20.0)*cubeSize, (posY+(odirY*anim+dirY*(20-anim))/20.0)*cubeSize, -cubeSize/6-5*sin(anim*PI/20.0),
                0, 0, -1);
      } else {
          camera(posX*cubeSize, posY*cubeSize,-cubeSize/6, 
                 (posX+dirX)*cubeSize, (posY+dirY)*cubeSize, -cubeSize/6,
                 0, 0, -1);
      }
    lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*cubeSize, posY*cubeSize, cubeSize/6);
    for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      pushMatrix();
      translate(i*wallW, j*wallH, 0);
      if (labyrinthe[j][i]=='#') {
        beginShape(QUADS);
        if (sides[j][i][3]==1) {
          pushMatrix();
          translate(0, -wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }

        if (sides[j][i][0]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
         if (sides[j][i][1]==1) {
          pushMatrix();
          translate(-wallW/2, 0, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
        if (sides[j][i][2]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
      } 
      popMatrix();
    }
  }
  shape(laby0, 0, 0);
  shape(ceiling0, 0, 0);
  translate(1*cubeSize, 6*cubeSize, -wallH);
  rotateZ(PI);
  shape(momie);
  
  } else{
    lightFalloff(0.0, 0.05, 0.0001);
    pointLight(255, 255, 255, posX*cubeSize, posY*cubeSize, cubeSize/6);
  }
  if(!inLab){
    perspective();
    camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
    noLights();
    stroke(0);
    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i+=LAB_SIZE-1) {
        if (labyrinthe[j][i]=='#') {
          fill(i*25, j*25, 255-i*10+j*10);
          pushMatrix();
          translate(50+i*cubeSize/8, 50+j*cubeSize/8, 50);
          box(cubeSize/10, cubeSize/10, 5);
          popMatrix();
        }
      }
    }
    for (int j=0; j<LAB_SIZE; j+=LAB_SIZE-1) {
      for (int i=1; i<LAB_SIZE-1; i++) {
        if (labyrinthe[j][i]=='#') {
          fill(i*25, j*25, 255-i*10+j*10);
          pushMatrix();
          translate(50+i*cubeSize/8, 50+j*cubeSize/8, 50);
          box(cubeSize/10, cubeSize/10, 5);
          popMatrix();
        }
      }
    }
    pushMatrix();
    fill(0, 255, 0);
    noStroke();
    translate(50+posX*cubeSize/8, 50+posY*cubeSize/8, 50);
    sphere(3);
    popMatrix();

     perspective(PI/3, float(width)/float(height), 1, 100000);
     if (animT){
         camera((posX-dirX*anim/20.0)*cubeSize,      (posY-dirY*anim/20.0)*cubeSize,      -cubeSize/6+2*sin(anim*PI/5.0), 
               (posX-dirX*anim/20.0+dirX)*cubeSize, (posY-dirY*anim/20.0+dirY)*cubeSize, -cubeSize/6+4*sin(anim*PI/5.0),
               0, 0, -1);
    }else if (animB){
        camera((posX+dirX*anim/20.0)*cubeSize,      (posY+dirY*anim/20.0)*cubeSize,      -cubeSize/6-2*sin(anim*PI/5.0), 
               (posX+dirX*anim/20.0+dirX)*cubeSize, (posY+dirY*anim/20.0+dirY)*cubeSize, -cubeSize/6-4*sin(anim*PI/5.0),
               0, 0, -1);
    }else if (animR){
        camera(posX*cubeSize, posY*cubeSize, -cubeSize/6, 
              (posX+(odirX*anim+dirX*(20-anim))/20.0)*cubeSize, (posY+(odirY*anim+dirY*(20-anim))/20.0)*cubeSize, -cubeSize/6-5*sin(anim*PI/20.0),
              0, 0, -1);
    } else {
        camera(posX*cubeSize, posY*cubeSize,-cubeSize/6, 
               (posX+dirX)*cubeSize, (posY+dirY)*cubeSize, -cubeSize/6,
               0, 0, -1);
    }
    lights();
    shape(ground, 0, -wallH);
    pushMatrix();
    translate(width/2, height/2, -wallH);
    shape(pyramid);
    popMatrix();
   }
  
  noStroke();
}

void keyPressed() {
 
    
  
  if(inLab){
    if (key=='o') {
      posX = 0;
      posY = -20;
      inLab = false;
    }
    if(anim==0 && keyCode == 38) {
      if(posX+dirX>=0 && posX+dirX<LAB_SIZE && posY+dirY>=0 && posY+dirY<LAB_SIZE &&
        labyrinthe[posY+dirY][posX+dirX]!='#') {
        posX += dirX;
        posY += dirY;
        anim = 20;
        animT = true;
        animR = false;
        animB = false;
      }
    }
    if (anim==0 && keyCode == 37) { // touche gauche
      // rotation de 90 degrés dans le sens anti-horaire
      odirX = dirX;
      odirY = dirY;
      newdirX = dirY;
      newdirY = -dirX;
      dirX = newdirX;
      dirY = newdirY;
      anim = 20;
      animT = false;
      animR = true;
      animB = false;
    }
    if (anim==0 && keyCode==40) {
      if(posX-dirX>=0 && posX-dirX<LAB_SIZE && posY-dirY>=0 && posY-dirY<LAB_SIZE &&
        labyrinthe[posY-dirY][posX-dirX]!='#'){
        posX-=dirX; 
        posY-=dirY;
        anim = 20;
        animT = false;
        animR = false;
        animB = true;
      }
    }
    if (anim==0 && keyCode==39) {
      // touche droite
      // rotation de 90 degrés dans le sens horaire
      odirX = dirX;
      odirY = dirY;
      newdirX = -dirY;
      newdirY = dirX;
      anim = 20;
      animT = false;
      animR = true;
      animB = false;
      dirX=newdirX; 
      dirY=newdirY;  
    }
  }
  if(!inLab){
    if (key=='l') {
      posX = iposX;
      posY = iposY;
      inLab = true;
    }
    if(anim==0 && keyCode == 38) {
        posX += dirX;
        posY += dirY;
        anim = 20;
        animT = true;
        animR = false;
        animB = false;
      
    }
    if (anim==0 && keyCode == 37) { // touche gauche
      // rotation de 90 degrés dans le sens anti-horaire
      odirX = dirX;
      odirY = dirY;
      newdirX = dirY;
      newdirY = -dirX;
      dirX = newdirX;
      dirY = newdirY;
      anim = 20;
      animT = false;
      animR = true;
      animB = false;
    }
    if (anim==0 && keyCode==40) {
        posX-=dirX; 
        posY-=dirY;
        anim = 20;
        animT = false;
        animR = false;
        animB = true;
    }
    if (anim==0 && keyCode==39) {
      // touche droite
      // rotation de 90 degrés dans le sens horaire
      odirX = dirX;
      odirY = dirY;
      newdirX = -dirY;
      newdirY = dirX;
      anim = 20;
      animT = false;
      animR = true;
      animB = false;
      dirX=newdirX; 
      dirY=newdirY;  
    }
  }
}
