import argparse
import matplotlib.pyplot as plt
import numpy as np
import csv
import cPickle as pickle
import time
import os, sys, stat
import os.path
import math
import keras

from netCDF4 import Dataset

from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.optimizers import SGD
from keras.utils import np_utils
from keras.callbacks import ModelCheckpoint, EarlyStopping
from keras.constraints import maxnorm

parser = argparse.ArgumentParser(description='MLP training and testing')
parser.add_argument('--save',dest='save',action='store_true', default=True,
                    help="if true, the network is serialized and saved")
parser.add_argument('--train',dest='train',action='store_true', default=False,
                    help=("if true, the network is trained from scratch from the"
                          "training data"))
parser.add_argument('--sparsity', dest='sparsity',action='store_true', default=False,
                    help=("if true, the the networks are trained with sparsity constraints"))
parser.add_argument('--nesterov', dest='nesterov',action='store_true', default=False,
                    help=("if true, the deep net is trained using nesterov momentum"))
parser.add_argument('--adversarial_training', dest='adversarial_training',action='store_true', default=False,
                    help=("if true, we use adversarial training"))
parser.add_argument('--rmsprop', dest='rmsprop',action='store_true', default=False,
                    help=("if true, rmsprop is used when training the deep net"))
parser.add_argument('--cv', dest='cv',action='store_true', default=False,
                    help=("if true, performs cv on the data"))
parser.add_argument('--display_main', dest='display_main',action='store_true', default=False,
                    help=("if true saves images of the net weights and samples from the net"))
parser.add_argument('--relu', dest='relu',action='store_true', default=False,
                    help=("if true, trains the net with a rectified linear unit"))
parser.add_argument('--NumberminiBatch', type=str, default='',
                    help='the number of training points in a mini batch')
parser.add_argument('--VisibleDropout', type=str, default='',
                    help='the drop out applied to dhe visible layers in dhe discriminative training')
parser.add_argument('--HiddenDropout', type=str, default='',
                    help='the drop out applied to dhe hidden layers in dhe discriminative training')
parser.add_argument('--MomentumMax', type=str, default='',
                    help='maximum value for the momentum in the MLP')
parser.add_argument('--RmsProp', dest='RmsProp', type=str, default='',
                    help='rmsprop in MLP')
parser.add_argument('--Adversarial_Training',  type=str, default='',
                    help='adversarial training is used if True')
parser.add_argument('--ES_epochs', type=str, default=5,
                    help="early stopping comes after ES_epochs epochs without no improvement in validation loss")




parser.add_argument('--fold', type=str, default=1,
                    help='the number of flods')
parser.add_argument('--COND', type=str, default=0,
                    help='the condition for having training or simply doing the test of the existing network')

parser.add_argument('--validation', dest='validation', action='store_true', default=False,
                    help="if true, the network is trained using a validation set")
parser.add_argument('--display', dest='display', action='store_true', default=False,
                    help="if true, figures will be displayed with matplotlib when available"
                          "Set to false when running the code via ssh, otherwise matplotlib"
                          "might crash.")

parser.add_argument('--nrLayers', type=str, default=2,
                    help="numbers of layers")
parser.add_argument('--layerSizes', metavar='N', nargs='+',
                    help="numbers of layers")
parser.add_argument('--learn_rate', type=str, default=0.01,
                    help="finetune learning rate")
parser.add_argument('--maxEpochs', type=str, default=100,
                    help="max epochs in the finetune process")

parser.add_argument('--train_file',
                    help="the path to the train files")
parser.add_argument('--test_file',
                    help="the path to the test files")
parser.add_argument('--val_file',
                    help="the path to the validation files")
parser.add_argument('--out_file',
                    help="the path to the output files")
parser.add_argument('--trained_network',
                    help="the path to the trainet nettwork")


# DEBUG mode?
parser.add_argument('--debug', dest='debug',action='store_true', default=False,
                    help=("if true, the deep belief net is ran in DEBUG mode"))

# Get the arguments of the program
args = parser.parse_args()



def mainMLP():
        begin_time  = time.time()
	print "Loading as Training set:"
	print str(args.train_file)
        tr_file=args.train_file
	print "Loading as Validation set:"
	print str(args.val_file)
        te_file=args.test_file
        v_file=args.val_file 

        fh_tr = Dataset(tr_file, mode='r')
        fh_te = Dataset(te_file, mode='r')
        fh_v = Dataset(v_file, mode='r')

        tr_data = fh_tr.variables['inputs'][:] #numpy arrays
        tr_labels_tmp = fh_tr.variables['targetPatterns'][:]
        tr_seqLen = fh_tr.variables['seqLengths'][:]

        te_data = fh_te.variables['inputs'][:] #numpy arrays
        te_labels_tmp = fh_te.variables['targetPatterns'][:]
        te_seqLen = fh_te.variables['seqLengths'][:]
        te_seqTAG = fh_te.variables['seqTags'][:]
        te_seqTAG = te_seqTAG.transpose()

        v_data = fh_v.variables['inputs'][:] #numpy arrays
        v_labels_tmp = fh_v.variables['targetPatterns'][:]
        v_seqLen = fh_v.variables['seqLengths'][:]
 
        fh_tr.close()     
        fh_te.close()  
        fh_v.close()  
         
        if len(tr_data[:,1]) < len(tr_data[1,:]):
           print 'Traspose the matrixes.....'      
           tr_data = tr_data.transpose()
           tr_labels_tmp = tr_labels_tmp.transpose()
           te_data = te_data.transpose()
           te_labels = te_labels.transpose()
           v_data = v_data.transpose()
           v_labels_tmp = v_labels_tmp.transpose()
           print '.......DONE'
     

        str_A = [args.out_file]
        file_name_A = ''.join(str_A)

	learn_rate = float(args.learn_rate)
	momentumax = float(args.MomentumMax)
	
 	ES_epochs = int(args.ES_epochs)
	maxEpochs = int(args.maxEpochs)

        sLls = list(args.layerSizes[0])
        tmp0 = ''.join(sLls)
	print(tmp0)
        sls = tmp0.split(',')
        nLls = [int(s) for s in sls]

	numberminibatch = int(args.NumberminiBatch)
        minibatchsize = int(math.ceil(len(tr_data)/numberminibatch)) 

	print minibatchsize

	HiddenDropout = float(args.HiddenDropout)	

        end_time = time.time()
        print('Preprocesing took %f minutes' % ((end_time - begin_time)/60.0))  
      
        if int(args.COND) == 0:
 	
	    begin_time  = time.time()	   

            model = Sequential()

            model.add(Dense(output_dim=nLls[1], input_dim=nLls[0], init='normal'))
            model.add(Activation('tanh'))
            #model.add(Dropout(HiddenDropout))
            model.add(Dense(output_dim=nLls[2], input_dim=nLls[1], init='normal'))
            model.add(Activation('tanh'))
            #model.add(Dropout(HiddenDropout))
            model.add(Dense(output_dim=4, input_dim=nLls[2], init='normal'))
            model.add(Activation('softmax'))
      
            
            sgd = SGD(lr=args.learn_rate, momentum=momentumax, nesterov=False)
            model.compile(loss='root_mean_squared_error', optimizer=sgd)

	    tr_labels = tr_labels_tmp
            v_labels = v_labels_tmp
            te_labels = te_labels_tmp

           
            print "Training is about to start....."

	    checkpointer = ModelCheckpoint(filepath=args.trained_network,verbose=0,save_best_only=True)
            ES = EarlyStopping(monitor='val_loss',patience=ES_epochs,verbose=0)
            model.fit(tr_data, tr_labels, validation_data = [v_data, v_labels], batch_size=minibatchsize, nb_epoch=maxEpochs, show_accuracy=True, verbose=2,  callbacks = [ES, checkpointer])
	    #model.fit(tr_data, tr_labels, validation_data = [v_data, v_labels], batch_size=minibatchsize, nb_epoch=maxEpochs, show_accuracy=True, verbose=2)

            print "Training  done.....it's about to start the test phase..........."
            print "saving and reloding the weights....."
	    print "Loading as Test set:"
	    print str(args.test_file)
            model.save_weights(args.trained_network, overwrite=True)
            model.load_weights(args.trained_network)
            print "......done"

            if (int(args.fold) == 1):
                simNRcont = 1
            else:
                simNRcont = (int(args.fold) - 1) *  len(te_seqLen)
                simNRcont += 1
            for simNR in xrange(len(te_seqLen)):
                #print(["test phase began.....nr: "+str(simNR+1)])
		O =  model.predict(te_data[simNR*te_seqLen[simNR]:(simNR+1)*te_seqLen[simNR],:], batch_size=5998, verbose=1)
		C_row=[]
		str_C_row=""
		for i in xrange (len(O)):
		    C_row_tmp = [r for r in O[i,:]]	
		    C_row=np.concatenate((C_row,C_row_tmp))
		str_C_row = ["%f" % number for number in C_row]
                label_C1 = ''.join(te_seqTAG[:,simNR])
                C_row = [label_C1+';'+';'.join(str_C_row)]
                simNRcont += 1
               
                if int(args.COND) == 0:

                    print "WRITING CSV FILES FOR THE RESULTS............"
                    with open(file_name_A, 'a') as csvfile1:
                                rowwriter_A = csv.writer(csvfile1) 
                                rowwriter_A.writerow(C_row)
		 		
                    csvfile1.close()
                    os.chmod(file_name_A, 0777)
 

                print(["test phase ends.....nr: "+str(simNR+1)])
	
	    end_time = time.time()
            print('Training took %f minutes' % ((end_time - begin_time)/60.0))  


        else:
            print "No model pretrain and finetune is done !!: the net is only going to be tested beacuse already exists......"
            print "loading the saved net....."
	    print "Loading as Test set:"
	    print str(args.test_file)
            model = Sequential()

            model.add(Dense(output_dim=nLls[1], input_dim=nLls[0], init='normal'))
            model.add(Activation('tanh'))
            #model.add(Dropout(HiddenDropout))
            model.add(Dense(output_dim=nLls[2], input_dim=nLls[1], init='normal'))
            model.add(Activation('tanh'))
            #model.add(Dropout(HiddenDropout))
            model.add(Dense(output_dim=4, input_dim=nLls[2], init='normal'))
            model.add(Activation('softmax'))
      
            
            sgd = SGD(lr=args.learn_rate, momentum=momentumax, nesterov=False)
            model.compile(loss='root_mean_squared_error', optimizer=sgd)

  	    tr_labels = tr_labels_tmp
            v_labels = v_labels_tmp
            te_labels = te_labels_tmp

            model.load_weights(args.trained_network)
            print ".......done"



            if (int(args.fold) == 1):
                    simNRcont = 1
            else:
                    simNRcont = (int(args.fold) - 1) *  len(te_seqLen)
                    simNRcont += 1
            for simNR in xrange(len(te_seqLen)):
                print(["test phase began.....nr: "+str(simNR+1)])
		O =  model.predict(te_data[simNR*te_seqLen[simNR]:(simNR+1)*te_seqLen[simNR],:], batch_size=5998, verbose=1)
		C_row=[]
		str_C_row=""
		for i in xrange (len(O)):
		    C_row_tmp = [r for r in O[i,:]]	
		    C_row=np.concatenate((C_row,C_row_tmp))
		str_C_row = ["%f" % number for number in C_row]
                label_C1 = ''.join(te_seqTAG[:,simNR])
                C_row = [label_C1+';'+';'.join(str_C_row)]
                simNRcont += 1
      
                print "WRITING CSV FILES FOR THE RESULTS............"
                with open(file_name_A, 'a') as csvfile1:
                            rowwriter_A = csv.writer(csvfile1) 
                            rowwriter_A.writerow(C_row)
		 		
                csvfile1.close()
                os.chmod(file_name_A, 0777)
 

                print(["test phase ends.....nr: "+str(simNR+1)])

def main():
  import random
  random.seed(6)
  np.random.seed(6)
  mainMLP()
if __name__ == '__main__':
  main()
