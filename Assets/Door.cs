using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour
{
    public float ZValue;
    public Camera camera;
    public GameObject puzzel;
    Vector3 puzzelScal;
    private void Start()
    {
        puzzelScal = puzzel.transform.localScale;
    }

    public void OpenDood()
    {
        //LeanTween.rotateZ(gameObject, 40, 1);
        LeanTween.rotateAroundLocal(gameObject, new Vector3(0, 0 , 1), ZValue, 3) ;
    }
    private void Update()
    {
        if (Vector3.Distance(this.transform.position, camera.transform.position) < 8 )
        {
           
            puzzel.SetActive(true);
            Debug.Log("hhh");
         
        }
       //else puzzel.SetActive(false);
        
    }

    IEnumerator DisplayPuzzel()
    {
        yield return new WaitForSeconds(1.5f);
        
    }


}
