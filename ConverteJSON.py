import sys
import json
import csv
import io

  
def filter_and_convert_to_csv(filename):
    
    if filename == 'yelp_academic_dataset_review.json':
  
        outputFile = open('yelp_academic_dataset_review.csv', 'w')
        campos= ['user_id', 'business_id', 'stars']     
        
        # "lineterminator='\n' serve para nao deixar uma linha vazia entre cada linha
        outputWriter = csv.DictWriter(outputFile, fieldnames = campos, lineterminator='\n')
        print ("Convertendo " + filename + " para " + "yelp_academic_dataset_review.csv ...")
    
        # le linha por linhe e escreve o user_id, business_id e stars para o CSV 
        for line in open(filename, 'r', encoding='utf-8'):
            r = json.loads(line)
            outputWriter.writerow({'user_id': r['user_id'], 'business_id': r['business_id'], 'stars': r['stars']})

    elif filename == 'yelp_academic_dataset_user.json':

        outputFile = open('yelp_academic_dataset_user.csv', 'w')
        campos= ['user_id', 'name']   

        outputWriter = csv.DictWriter(outputFile, fieldnames = campos, lineterminator='\n')
        print ("Convertendo " + filename + " para " + "yelp_academic_user_review.csv ...")
    
        # le linha por linhe e escreve o user_id e name para o CSV 
        for line in open(filename, 'r', encoding='utf-8'):
            r = json.loads(line)
            
            # para lidar com valores de nomes com unicode usa-se encode para remover os caracteres unicode
            # isso evita que ocorra um problema em writerow que nao lida bem com unicode
            n = r['name']
            n1 = n.encode('ascii', 'ignore')
            outputWriter.writerow({'user_id': r['user_id'], 'name': n1})
          
    elif filename == 'yelp_academic_dataset_business.json':
  
        outputFile = open('yelp_academic_dataset_business.csv', 'w')
        campos= ['business_id', 'city', 'name', 'categories', 'review_count', 'stars']     
        outputWriter = csv.DictWriter(outputFile, fieldnames = campos, lineterminator='\n')
        print ("Convertendo " + filename + " para " + "yelp_academic_dataset_review.csv ...")
        
        # le linha por linha e escreve os campos relevantes se o negocio for um restaurante
        for line in open(filename, 'r', encoding='utf-8'):
            r = json.loads(line)
            categories = str(r['categories'])
            if "Restaurants" in categories:
                n = r['name']
                n1 = n.encode('ascii', 'ignore')
                c = r['city']
                c1 = c.encode('ascii', 'ignore')
                outputWriter.writerow({'business_id': r['business_id'], 'city': c1, 'name': n1, 'categories': r['categories'], 
                                    'review_count': r['review_count'], 'stars': r['stars']})
                                  
    else: 
  
        print ("Error!  Unexpected filename used.")
        exit()
                
    outputFile.close

  
  
def main():
    # This command-line parsing code is provided.
    # Make a list of command line arguments, omitting the [0] element
    # which is the script itself.
    args = sys.argv[1:]
        
    if not args:
        print ('usage: file')
        sys.exit(1)

    filter_and_convert_to_csv(sys.argv[1])
  
if __name__ == '__main__':
  main()