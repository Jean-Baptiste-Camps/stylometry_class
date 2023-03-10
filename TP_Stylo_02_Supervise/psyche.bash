# Training data
python main.py -s data/psyche/train/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size 400

# Leave one out
python train_svm.py PSYCHE_TRAIN_feats_tests_n3_k_5000.csv --cross_validate leave-one-out

# Unseen data
python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json  --sampling --sample_units verses --sample_size 400

# Final pred
python train_svm.py PSYCHE_TRAIN_feats_tests_n3_k_5000.csv  --test_path PSYCHE_TEST_feats_tests_n3_k_5000.csv --final

# Unseen with overlap

python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json  --sampling --sample_units verses --sample_size 150 --sample_step 1

python train_svm.py PSYCHE_TRAIN_feats_tests_n3_k_5000.csv  --test_path PSYCHE_TEST_OVERLAP_feats_tests_n3_k_5000.csv --final

## Tests diverses longueurs

Samples de 200 vers
IN-DOMAIN
.......... using 52 samples ........
               precision    recall  f1-score   support

        BOYER       1.00      1.00      1.00        10
   CORNEILLEP       1.00      1.00      1.00        11
   CORNEILLET       1.00      1.00      1.00        11
DONNEAUDEVISE       1.00      1.00      1.00        10
      MOLIERE       1.00      1.00      1.00        10

     accuracy                           1.00        52
    macro avg       1.00      1.00      1.00        52
 weighted avg       1.00      1.00      1.00        52

OUT-OF-DOMAIN
              precision    recall  f1-score   support

        BOYER       0.78      0.78      0.78         9
   CORNEILLEP       0.27      0.89      0.41         9
   CORNEILLET       0.00      0.00      0.00        10
DONNEAUDEVISE       1.00      1.00      1.00         8
      MOLIERE       0.67      0.22      0.33         9
     QUINAULT       0.00      0.00      0.00         8

     accuracy                           0.47        53
    macro avg       0.45      0.48      0.42        53
 weighted avg       0.44      0.47      0.41        53



python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json  --sampling --sample_units verses --sample_size 200 --sample_step 50

python train_svm.py PSYCHE_TRAIN_200l_feats_tests_n3_k_5000.csv  --test_path PSYCHE_TEST_l200step50_feats_tests_n3_k_5000.csv --final

#### Tests out of domain
python main.py -s data/psyche/outofdomain/* -t chars -n 3 -x tei -f PSYCHE_size200_feature_list.json  --sampling --sample_units verses --sample_size 200
python train_svm.py PSYCHE_size200_TrainBis.csv  --test_path PSYCHE_size200_OUTOFDOMAIN.csv

#### Tests BIG corpus
python main.py -s data/psyche/train_BIG/* -t chars -n 3 -x tei --sampling --sample_units verses --sample_size 200
python train_svm.py PSYCHE_BIG_feats_tests_n3_k_5000.csv --cross_validate leave-one-out
.......... using 912 samples ........
               precision    recall  f1-score   support

        BOYER       1.00      0.99      1.00       101
   CORNEILLEP       0.99      1.00      1.00       324
   CORNEILLET       0.98      0.99      0.99       263
DONNEAUDEVISE       1.00      0.97      0.99        35
      MOLIERE       0.94      0.97      0.95        87
     QUINAULT       0.99      0.95      0.97       102

     accuracy                           0.99       912
    macro avg       0.98      0.98      0.98       912
 weighted avg       0.99      0.99      0.99       912

python train_svm.py PSYCHE_BIG_feats_tests_n3_k_5000.csv  --test_path feats_tests_n3_k_5000.csv
               precision    recall  f1-score   support

        BOYER       1.00      1.00      1.00         9
   CORNEILLEP       0.82      1.00      0.90         9
   CORNEILLET       0.71      1.00      0.83        10
DONNEAUDEVISE       1.00      1.00      1.00         8
      MOLIERE       1.00      0.67      0.80         9
     QUINAULT       1.00      0.62      0.77         8

     accuracy                           0.89        53
    macro avg       0.92      0.88      0.88        53
 weighted avg       0.92      0.89      0.88        53

python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f PSYCHE_BIG_feature_list_chars3grams5000mf.json  --sampling --sample_units verses --sample_size 200 --sample_step 20

python train_svm.py PSYCHE_BIG_feats_tests_n3_k_5000.csv  --test_path PSYCHE_BIG_TEST_size200_step20.csv --final


### Benchmark differents lengths
## Small Corpus
for i in `seq 50 50 500`; do
  echo $i >> psyche_train_benchmark.log
  python main.py -s data/psyche/train/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size $i
  # Leave one out
  python train_svm.py feats_tests_n3_k_5000.csv --cross_validate leave-one-out >> psyche_train_benchmark.log
done

for i in `seq 10 10 40`; do
  echo $i >> psyche_train_benchmark.log
  python main.py -s data/psyche/train/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size $i
  # Leave one out
  python train_svm.py feats_tests_n3_k_5000.csv --cross_validate leave-one-out >> psyche_train_benchmark.log
done

## Big Corpus
for i in `seq 50 50 500`; do
  echo $i >> psyche_train_BIG_benchmark.log
  python main.py -s data/psyche/train_BIG/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size $i
  mv feats_tests_n3_k_5000.csv train.csv
  python main.py -s data/psyche/outofdomain/*.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json --sampling --sample_units verses --sample_size $i
  mv feats_tests_n3_k_5000.csv test.csv
  # Leave one out
  python train_svm.py train.csv --test_path test.csv >> psyche_train_BIG_benchmark.log
done

for i in `seq 10 10 40`; do
  echo $i >> psyche_train_BIG_benchmark.log
  python main.py -s data/psyche/train_BIG/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size $i
  mv feats_tests_n3_k_5000.csv train.csv
  python main.py -s data/psyche/outofdomain/*.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json --sampling --sample_units verses --sample_size $i
  mv feats_tests_n3_k_5000.csv test.csv
  # Leave one out
  python train_svm.py train.csv --test_path test.csv >> psyche_train_BIG_benchmark.log
done


### Small s150
python main.py -s data/psyche/train/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size 150
mv feats_tests_n3_k_5000.csv train_small_size150.csv
mv feature_list_chars3grams5000mf.json feature_list_small_s150.json
python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f feature_list_small_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv test_psyche_size150v_step1v_small.csv
python train_svm.py train_small_size150.csv --test_path test_psyche_size150v_step1v_small.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_small150v.csv

python main.py -s data/psyche/unseen/CORNEILLET_INCONNU.xml -t chars -n 3 -x tei -f feature_list_small_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv unseen_Inconnu_small.csv
python train_svm.py train_small_size150.csv --test_path unseen_Inconnu_small.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_Inconnu_small.csv
python main.py -s data/psyche/unseen/CORNEILLET_CIRCE.xml -t chars -n 3 -x tei -f feature_list_small_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv unseen_Circe_small.csv
python train_svm.py train_small_size150.csv --test_path unseen_Circe_small.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_Circe_small.csv


### Big s150
python main.py -s data/psyche/train_BIG/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size 150
mv feats_tests_n3_k_5000.csv train_big_size150.csv
mv feature_list_chars3grams5000mf.json feature_list_big_s150.json
python main.py -s data/psyche/unseen/MOLIERE_PSYCHE.xml -t chars -n 3 -x tei -f feature_list_big_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv test_psyche_size150v_step1v_big.csv
python train_svm.py train_big_size150.csv --test_path test_psyche_size150v_step1v_big.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_big150v.csv
# Et les deux autres
python main.py -s data/psyche/unseen/CORNEILLET_CIRCE.xml -t chars -n 3 -x tei -f feature_list_big_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv unseen_circe.csv
python train_svm.py train_big_size150.csv --test_path unseen_circe.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_circe.csv
python main.py -s data/psyche/unseen/CORNEILLET_INCONNU.xml -t chars -n 3 -x tei -f feature_list_big_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
mv feats_tests_n3_k_5000.csv unseen_Inconnu.csv
python train_svm.py train_big_size150.csv --test_path unseen_Inconnu.csv --final
mv FINAL_PREDICTIONS.csv FINAL_PREDICTIONS_Inconnu.csv

#python main.py -s data/psyche/unseen/DONNEAUDEVISE-CORNEILLE_DONNEAUDEVISE-CORNEILLEDEVINERESSE.xml -t chars -n 3 -x tei -f feature_list_big_s150.json  --sampling --sample_units verses --sample_size 150 --sample_step 1
#python train_svm.py train_big_size150.csv --test_path unseen_devineresse.csv --final

## OTHER TEST

#### BENCHMARK UPSAMPLING STRATEGIES
python main.py -s data/psyche/train_BIG/*.xml -t chars -n 3 -x tei --sampling --sample_units verses --sample_size 200
mv feats_tests_n3_k_5000.csv train.csv
python main.py -s data/psyche/outofdomain/*.xml -t chars -n 3 -x tei -f feature_list_chars3grams5000mf.json --sampling --sample_units verses --sample_size 200
mv feats_tests_n3_k_5000.csv test.csv
# testing strategies
echo "NO STRATEGY" | tee -a evaluating_sampling_strategies.md
python train_svm.py train.csv --test_path test.csv  | tee -a evaluating_sampling_strategies.md
for i in {class_weight,downsampling,Tomek,upsampling,SMOTE,SMOTETomek}; do
  echo $i | tee -a evaluating_sampling_strategies.md
  python train_svm.py train.csv --test_path test.csv --balance $i  | tee -a evaluating_sampling_strategies.md
done