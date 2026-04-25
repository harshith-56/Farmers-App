Result: 
        RandomForestClassifier
        criterion = "entropy"
        max_depth = 10
        n_estimators = 50
This model gave the highest accuracy : 
Cross Validation Accuracy : 99.60%
Test Accuracy             : 99.32%




======================================
Training Model: Logistic Regression
======================================
Fitting 5 folds for each of 4 candidates, totalling 20 fits
[CV] END ......................................model__C=0.01; total time=   0.0s
[CV] END ......................................model__C=0.01; total time=   0.0s
[CV] END ......................................model__C=0.01; total time=   0.0s
[CV] END ......................................model__C=0.01; total time=   0.0s
[CV] END ......................................model__C=0.01; total time=   0.0s
[CV] END .......................................model__C=0.1; total time=   0.0s
[CV] END .......................................model__C=0.1; total time=   0.0s
[CV] END .......................................model__C=0.1; total time=   0.0s
[CV] END .......................................model__C=0.1; total time=   0.0s
[CV] END .......................................model__C=0.1; total time=   0.0s
[CV] END .........................................model__C=1; total time=   0.0s
[CV] END .........................................model__C=1; total time=   0.0s
[CV] END .........................................model__C=1; total time=   0.0s
[CV] END .........................................model__C=1; total time=   0.0s
[CV] END .........................................model__C=1; total time=   0.0s
[CV] END ........................................model__C=10; total time=   0.0s
[CV] END ........................................model__C=10; total time=   0.0s
[CV] END ........................................model__C=10; total time=   0.0s
[CV] END ........................................model__C=10; total time=   0.0s
[CV] END ........................................model__C=10; total time=   0.0s

All Parameter Combinations:
Params: {'model__C': 0.01} | Mean CV Accuracy: 0.7898
Params: {'model__C': 0.1} | Mean CV Accuracy: 0.9335
Params: {'model__C': 1} | Mean CV Accuracy: 0.9699
Params: {'model__C': 10} | Mean CV Accuracy: 0.979

Best Parameters: {'model__C': 10}
Best CV Accuracy: 0.979
Test Accuracy: 0.9705

======================================
Training Model: KNN
======================================
Fitting 5 folds for each of 8 candidates, totalling 40 fits
[CV] END .....................n_neighbors=3, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=3, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=3, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=3, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=3, weights=uniform; total time=   0.0s
[CV] END ....................n_neighbors=3, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=3, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=3, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=3, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=3, weights=distance; total time=   0.0s
[CV] END .....................n_neighbors=5, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=5, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=5, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=5, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=5, weights=uniform; total time=   0.0s
[CV] END ....................n_neighbors=5, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=5, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=5, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=5, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=5, weights=distance; total time=   0.0s
[CV] END .....................n_neighbors=7, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=7, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=7, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=7, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=7, weights=uniform; total time=   0.0s
[CV] END ....................n_neighbors=7, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=7, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=7, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=7, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=7, weights=distance; total time=   0.0s
[CV] END .....................n_neighbors=9, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=9, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=9, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=9, weights=uniform; total time=   0.0s
[CV] END .....................n_neighbors=9, weights=uniform; total time=   0.0s
[CV] END ....................n_neighbors=9, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=9, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=9, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=9, weights=distance; total time=   0.0s
[CV] END ....................n_neighbors=9, weights=distance; total time=   0.0s

All Parameter Combinations:
Params: {'n_neighbors': 3, 'weights': 'uniform'} | Mean CV Accuracy: 0.9801
Params: {'n_neighbors': 3, 'weights': 'distance'} | Mean CV Accuracy: 0.9807
Params: {'n_neighbors': 5, 'weights': 'uniform'} | Mean CV Accuracy: 0.9807
Params: {'n_neighbors': 5, 'weights': 'distance'} | Mean CV Accuracy: 0.983
Params: {'n_neighbors': 7, 'weights': 'uniform'} | Mean CV Accuracy: 0.9807
Params: {'n_neighbors': 7, 'weights': 'distance'} | Mean CV Accuracy: 0.9812
Params: {'n_neighbors': 9, 'weights': 'uniform'} | Mean CV Accuracy: 0.9773
Params: {'n_neighbors': 9, 'weights': 'distance'} | Mean CV Accuracy: 0.9801

Best Parameters: {'n_neighbors': 5, 'weights': 'distance'}
Best CV Accuracy: 0.983
Test Accuracy: 0.9705

======================================
Training Model: Decision Tree
======================================
Fitting 5 folds for each of 8 candidates, totalling 40 fits
[CV] END .....................criterion=gini, max_depth=None; total time=   0.0s
[CV] END .....................criterion=gini, max_depth=None; total time=   0.0s
[CV] END .....................criterion=gini, max_depth=None; total time=   0.0s
[CV] END .....................criterion=gini, max_depth=None; total time=   0.0s
[CV] END .....................criterion=gini, max_depth=None; total time=   0.0s
[CV] END ........................criterion=gini, max_depth=5; total time=   0.0s
[CV] END ........................criterion=gini, max_depth=5; total time=   0.0s
[CV] END ........................criterion=gini, max_depth=5; total time=   0.0s
[CV] END ........................criterion=gini, max_depth=5; total time=   0.0s
[CV] END ........................criterion=gini, max_depth=5; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=10; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=10; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=10; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=10; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=10; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=15; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=15; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=15; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=15; total time=   0.0s
[CV] END .......................criterion=gini, max_depth=15; total time=   0.0s
[CV] END ..................criterion=entropy, max_depth=None; total time=   0.0s
[CV] END ..................criterion=entropy, max_depth=None; total time=   0.0s
[CV] END ..................criterion=entropy, max_depth=None; total time=   0.0s
[CV] END ..................criterion=entropy, max_depth=None; total time=   0.0s
[CV] END ..................criterion=entropy, max_depth=None; total time=   0.0s
[CV] END .....................criterion=entropy, max_depth=5; total time=   0.0s
[CV] END .....................criterion=entropy, max_depth=5; total time=   0.0s
[CV] END .....................criterion=entropy, max_depth=5; total time=   0.0s
[CV] END .....................criterion=entropy, max_depth=5; total time=   0.0s
[CV] END .....................criterion=entropy, max_depth=5; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=10; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=10; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=10; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=10; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=10; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=15; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=15; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=15; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=15; total time=   0.0s
[CV] END ....................criterion=entropy, max_depth=15; total time=   0.0s

All Parameter Combinations:
Params: {'criterion': 'gini', 'max_depth': None} | Mean CV Accuracy: 0.9852
Params: {'criterion': 'gini', 'max_depth': 5} | Mean CV Accuracy: 0.4847
Params: {'criterion': 'gini', 'max_depth': 10} | Mean CV Accuracy: 0.9869
Params: {'criterion': 'gini', 'max_depth': 15} | Mean CV Accuracy: 0.9841
Params: {'criterion': 'entropy', 'max_depth': None} | Mean CV Accuracy: 0.9773
Params: {'criterion': 'entropy', 'max_depth': 5} | Mean CV Accuracy: 0.908
Params: {'criterion': 'entropy', 'max_depth': 10} | Mean CV Accuracy: 0.9761
Params: {'criterion': 'entropy', 'max_depth': 15} | Mean CV Accuracy: 0.9778

Best Parameters: {'criterion': 'gini', 'max_depth': 10}
Best CV Accuracy: 0.9869
Test Accuracy: 0.9886

======================================
Training Model: Random Forest
======================================
Fitting 5 folds for each of 18 candidates, totalling 90 fits
[CV] END ....criterion=gini, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END ....criterion=gini, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END ....criterion=gini, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END ....criterion=gini, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END ....criterion=gini, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END ...criterion=gini, max_depth=None, n_estimators=100; total time=   0.3s
[CV] END ...criterion=gini, max_depth=None, n_estimators=100; total time=   0.3s
[CV] END ...criterion=gini, max_depth=None, n_estimators=100; total time=   0.3s
[CV] END ...criterion=gini, max_depth=None, n_estimators=100; total time=   0.3s
[CV] END ...criterion=gini, max_depth=None, n_estimators=100; total time=   0.5s
[CV] END ...criterion=gini, max_depth=None, n_estimators=200; total time=   0.9s
[CV] END ...criterion=gini, max_depth=None, n_estimators=200; total time=   0.7s
[CV] END ...criterion=gini, max_depth=None, n_estimators=200; total time=   0.9s
[CV] END ...criterion=gini, max_depth=None, n_estimators=200; total time=   0.8s
[CV] END ...criterion=gini, max_depth=None, n_estimators=200; total time=   0.7s
[CV] END ......criterion=gini, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=10, n_estimators=50; total time=   0.2s
[CV] END ......criterion=gini, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END .....criterion=gini, max_depth=10, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=10, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=10, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=10, n_estimators=100; total time=   0.2s
[CV] END .....criterion=gini, max_depth=10, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=10, n_estimators=200; total time=   0.5s
[CV] END .....criterion=gini, max_depth=10, n_estimators=200; total time=   0.5s
[CV] END .....criterion=gini, max_depth=10, n_estimators=200; total time=   0.6s
[CV] END .....criterion=gini, max_depth=10, n_estimators=200; total time=   0.5s
[CV] END .....criterion=gini, max_depth=10, n_estimators=200; total time=   0.5s
[CV] END ......criterion=gini, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END ......criterion=gini, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END .....criterion=gini, max_depth=20, n_estimators=100; total time=   0.2s
[CV] END .....criterion=gini, max_depth=20, n_estimators=100; total time=   0.2s
[CV] END .....criterion=gini, max_depth=20, n_estimators=100; total time=   0.2s
[CV] END .....criterion=gini, max_depth=20, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=20, n_estimators=100; total time=   0.3s
[CV] END .....criterion=gini, max_depth=20, n_estimators=200; total time=   0.5s
[CV] END .....criterion=gini, max_depth=20, n_estimators=200; total time=   0.6s
[CV] END .....criterion=gini, max_depth=20, n_estimators=200; total time=   0.5s
[CV] END .....criterion=gini, max_depth=20, n_estimators=200; total time=   0.6s
[CV] END .....criterion=gini, max_depth=20, n_estimators=200; total time=   0.4s
[CV] END .criterion=entropy, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END .criterion=entropy, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END .criterion=entropy, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END .criterion=entropy, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END .criterion=entropy, max_depth=None, n_estimators=50; total time=   0.1s
[CV] END criterion=entropy, max_depth=None, n_estimators=100; total time=   0.5s
[CV] END criterion=entropy, max_depth=None, n_estimators=100; total time=   0.6s
[CV] END criterion=entropy, max_depth=None, n_estimators=100; total time=   0.4s
[CV] END criterion=entropy, max_depth=None, n_estimators=100; total time=   0.5s
[CV] END criterion=entropy, max_depth=None, n_estimators=100; total time=   0.4s
[CV] END criterion=entropy, max_depth=None, n_estimators=200; total time=   1.2s
[CV] END criterion=entropy, max_depth=None, n_estimators=200; total time=   0.9s
[CV] END criterion=entropy, max_depth=None, n_estimators=200; total time=   0.8s
[CV] END criterion=entropy, max_depth=None, n_estimators=200; total time=   0.9s
[CV] END criterion=entropy, max_depth=None, n_estimators=200; total time=   0.8s
[CV] END ...criterion=entropy, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ...criterion=entropy, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ...criterion=entropy, max_depth=10, n_estimators=50; total time=   0.1s
[CV] END ...criterion=entropy, max_depth=10, n_estimators=50; total time=   0.2s
[CV] END ...criterion=entropy, max_depth=10, n_estimators=50; total time=   0.2s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=100; total time=   0.6s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=100; total time=   0.4s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=100; total time=   0.4s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=100; total time=   0.5s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=100; total time=   0.6s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=200; total time=   0.9s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=200; total time=   0.7s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=200; total time=   0.8s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=200; total time=   0.6s
[CV] END ..criterion=entropy, max_depth=10, n_estimators=200; total time=   0.6s
[CV] END ...criterion=entropy, max_depth=20, n_estimators=50; total time=   0.1s
[CV] END ...criterion=entropy, max_depth=20, n_estimators=50; total time=   0.2s
[CV] END ...criterion=entropy, max_depth=20, n_estimators=50; total time=   0.3s
[CV] END ...criterion=entropy, max_depth=20, n_estimators=50; total time=   0.4s
[CV] END ...criterion=entropy, max_depth=20, n_estimators=50; total time=   0.3s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=100; total time=   0.7s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=100; total time=   0.5s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=100; total time=   0.4s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=100; total time=   0.4s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=100; total time=   0.4s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=200; total time=   0.8s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=200; total time=   0.8s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=200; total time=   0.8s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=200; total time=   0.7s
[CV] END ..criterion=entropy, max_depth=20, n_estimators=200; total time=   1.3s

All Parameter Combinations:
Params: {'criterion': 'gini', 'max_depth': None, 'n_estimators': 50} | Mean CV Accuracy: 0.9932
Params: {'criterion': 'gini', 'max_depth': None, 'n_estimators': 100} | Mean CV Accuracy: 0.9932
Params: {'criterion': 'gini', 'max_depth': None, 'n_estimators': 200} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'gini', 'max_depth': 10, 'n_estimators': 50} | Mean CV Accuracy: 0.9926
Params: {'criterion': 'gini', 'max_depth': 10, 'n_estimators': 100} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'gini', 'max_depth': 10, 'n_estimators': 200} | Mean CV Accuracy: 0.9932
Params: {'criterion': 'gini', 'max_depth': 20, 'n_estimators': 50} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'gini', 'max_depth': 20, 'n_estimators': 100} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'gini', 'max_depth': 20, 'n_estimators': 200} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'entropy', 'max_depth': None, 'n_estimators': 50} | Mean CV Accuracy: 0.9955
Params: {'criterion': 'entropy', 'max_depth': None, 'n_estimators': 100} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'entropy', 'max_depth': None, 'n_estimators': 200} | Mean CV Accuracy: 0.9926
Params: {'criterion': 'entropy', 'max_depth': 10, 'n_estimators': 50} | Mean CV Accuracy: 0.996
Params: {'criterion': 'entropy', 'max_depth': 10, 'n_estimators': 100} | Mean CV Accuracy: 0.9949
Params: {'criterion': 'entropy', 'max_depth': 10, 'n_estimators': 200} | Mean CV Accuracy: 0.9932
Params: {'criterion': 'entropy', 'max_depth': 20, 'n_estimators': 50} | Mean CV Accuracy: 0.9938
Params: {'criterion': 'entropy', 'max_depth': 20, 'n_estimators': 100} | Mean CV Accuracy: 0.9932
Params: {'criterion': 'entropy', 'max_depth': 20, 'n_estimators': 200} | Mean CV Accuracy: 0.9943

Best Parameters: {'criterion': 'entropy', 'max_depth': 10, 'n_estimators': 50}
Best CV Accuracy: 0.996
Test Accuracy: 0.9932


